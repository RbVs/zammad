# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

# Base class for background services
class BackgroundServices::Service
  include Mixin::RequiredSubPaths

  def self.max_workers
    1
  end
end
