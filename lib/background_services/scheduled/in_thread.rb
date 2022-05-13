# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  class Scheduled
    class InThread
      attr_reader :job, :jobs_container

      def initialize(job, jobs_container)
        @job            = job
        @jobs_container = jobs_container
      end

      def launch
        if loop?
          run_loop
        else
          start
        end
      end

      def run_loop
        # only do a certain amount of loops in this thread
        1_800.times do
          start
          @job = Scheduler.lookup(id: job.id)

          break if !continue_loop?(job)

          # wait until next run
          sleep job.period
        end
      end

      def loop?(job)
        # start loop for periods equal or under 5 minutes
        job.period && job.period <= 5.minutes
      end

      def continue_loop?(job)
        job&.active && job&.period
      end

      def start
        Start.new(job, jobs_container).start
      end
    end
  end
end
