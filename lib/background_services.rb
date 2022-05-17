# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices

  def self.available_services
    BackgroundServices::Service.descendants
  end

  def run
    Rails.logger.debug 'Starting BackgroundServices...'

    self.class.available_services.each do |service|
      run_service service
    end

    Process.waitall

    loop do
      sleep 1
    end
  rescue Interrupt
    nil
  ensure
    Rails.logger.debug('Stopping BackgroundServices.')
  end

  def run_service(service)
    service_name = service.name.demodulize
    env_prefix   = "ZAMMAD_#{service_name.underscore.upcase}"
    if ENV["#{env_prefix}_DISABLED"]
      Rails.logger.debug { "Skipping disabled service #{service_name}." }
      return
    end

    service_workers = ENV["#{env_prefix}_WORKERS"].to_i

    if service_workers.positive?
      forks = [service_workers, service.max_workers].min
      start_as_forks(service, service_name, forks)
    else
      start_as_thread(service, service_name)
    end
  end

  def start_as_forks(service, service_name, forks)
    (1..forks).each do
      Process.fork do
        Rails.logger.debug { "Starting process ##{Process.pid} for service #{service_name}." }
        refresh
        service.new.run
      rescue Interrupt
        nil
      end
    end
  end

  def start_as_thread(service, service_name)
    ProcessingThread.new do
      Rails.logger.debug { "Starting thread for service #{service_name} in the main process." }
      Thread.current.abort_on_exception = true
      refresh
      service.new.run
    end
  end

  def refresh
    begin
      ActiveRecord::Base.connection.reconnect!
    rescue => e
      Rails.logger.error "Can't reconnect to database #{e.inspect}"
    end
  end
end
