# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  module Service
    class ProcessScheduledJobs
      class RetryLimitReached < StandardError
      end
    end
  end
end
