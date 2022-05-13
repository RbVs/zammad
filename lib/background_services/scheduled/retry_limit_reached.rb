# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  class Scheduled
    class RetryLimitReached < StandardError
    end
  end
end
