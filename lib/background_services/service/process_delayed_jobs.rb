# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  module Service
    class ProcessDelayedJobs
      WAIT = 4

      def initialize
        cleanup
        run
      end

      def run
        ApplicationHandleInfo.use('scheduler') do
          loop do
            result = nil

            realtime = Benchmark.realtime do
              Rails.logger.debug { "*** worker thread, #{::Delayed::Job.all.count} in queue" }
              result = ::Delayed::Worker.new.work_off
            end

            process_results(result, realtime)
          end
        end
      end

      def process_results(result, realtime)
        count = result.sum

        if count.zero?
          sleep WAIT
          Rails.logger.debug { '*** worker thread loop' }
        else
          Rails.logger.debug { format "*** #{count} jobs processed at %<jps>.4f j/s, %<failed>d failed ...\n", jps: count / realtime, failed: result.last }
        end
      end

      def cleanup(force: false)
        start_time = Time.zone.now

        CleanupAction.cleanup_delayed_jobs(start_time)
        ImportJob.cleanup_import_jobs(start_time)
      end
    end
  end
end
