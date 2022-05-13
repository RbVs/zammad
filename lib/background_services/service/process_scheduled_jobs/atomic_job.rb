# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  module Service
    class ProcessScheduledJobs
      class AtomicJob
        attr_reader :job, :try_count, :try_run_time, :started_at

        def initialize(job)
          @job            = job
          @try_count      = 0
          @try_run_time   = Time.current
        end

        def launch
          start
        end

        # def _start_job(job, try_count = 0, try_run_time = Time.zone.now)
        def start
          mark_as_started
          execute
        rescue => e
          log_error(e)

          # reconnect in case db connection is lost
          begin
            ActiveRecord::Base.connection.reconnect!
          rescue => e
            Rails.logger.error "Can't reconnect to database #{e.inspect}"
          end

          retry_execution

        # rescue any other Exceptions that are not StandardError or childs of it
        # https://stackoverflow.com/questions/10048173/why-is-it-bad-style-to-rescue-exception-e-in-ruby
        # http://rubylearning.com/satishtalim/ruby_exceptions.html
        rescue Exception => e # rubocop:disable Lint/RescueException
          log_error(e)
          raise
        ensure
          ActiveSupport::CurrentAttributes.clear_all
        end

        def execute
          Rails.logger.info "execute #{job.method} (try_count #{try_count})..."
          eval job.method # rubocop:disable Security/Eval
          Rails.logger.info "ended #{job.method} took: #{since_started} seconds."
        end

        def log_error(e)
          error_description = e.is_a?(StandardError) ? 'error' : 'a non standard error'

          Rails.logger.error "execute #{job.method} (try_count #{try_count}) exited with #{error_description} #{e.inspect} in: #{since_started} seconds."
        end

        def mark_as_started
          @started_at = Time.current

          job.update!(
            last_run:      started_at,
            pid:           Thread.current.object_id,
            status:        'ok',
            error_message: '',
          )
        end

        def since_started
          Time.current - started_at
        end

        TRY_RUN_MAX = 10

        def retry_execution
          @try_count += 1

          # reset error counter if to old
          if try_run_time < 5.minutes.ago
            @try_count = 0
          end

          if @try_count > TRY_RUN_MAX
            retry_limit_reached

            return
          end

          sleep(try_count) if Rails.env.production?
          start
        end

        def retry_limit_reached
          error = "Failed to run #{job.method} after #{try_count} tries #{e.inspect}"
          Rails.logger.error error

          job.update!(
            error_message: error,
            status:        'error',
            active:        false,
          )

          raise RetryLimitReached
        end
      end
    end
  end
end
