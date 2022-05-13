# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  def run
    Thread.abort_on_exception = true

    [BackgroundServices::Delayed, BackgroundServices::Scheduled].each do |service|
      start(service)
    end

    loop do
      sleep 1
    end
  end

  def start(service)
    Thread.new do
      begin
        ActiveRecord::Base.connection.reconnect!
      rescue => e
        Rails.logger.error "Can't reconnect to database #{e.inspect}"
      end

      service.new.run
    end
  end
end
