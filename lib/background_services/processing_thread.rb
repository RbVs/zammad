# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  class ProcessingThread < DelegateClass(::Thread)
    def initialize(abort: false, &block)
      @thread = ::Thread.new do
        Thread.current.abort_on_exception = true if abort

        Rails.application.executor.wrap do
          ApplicationHandleInfo.use('scheduler', &block)
        end
      end

      super(@thread)
    end
  end
end
