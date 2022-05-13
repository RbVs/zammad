# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  class Service
    class ProcessScheduledJobs < Service
      attr_reader :jobs_started

      def initialize
        super
        @jobs_started = {}
      end

      def run
        loop do
          Rails.logger.info 'Scheduler running...'

          scope.each do |job|
            Manager
              .new(job, jobs_started)
              .run

            sleep 10
          end
          sleep 60
        end
      end

      private

      def scope
        Scheduler.where(active: true).order(prio: :asc)
      end
    end
  end
end
