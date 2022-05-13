# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  class Scheduled
    class LoopJob < AtomicJob
      LOOP_LIMIT = 1_800

      def launch
        run_loop
      end

      def continue_loop?(job)
        job&.active && job&.period
      end

      def run_loop
        # only do a certain amount of loops in this thread
        LOOP_LIMIT.times do
          start
          @job = Scheduler.lookup(id: job.id)

          break if !job.runs_as_persistent_loop?

          # wait until next run
          sleep job.period
        end
      end
    end
  end
end
