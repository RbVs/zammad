# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  class Cli < Thor
    # rubocop:disable Zammad/DetectTranslatableString

    SERVICES = %w[background-jobs scheduled-jobs session-jobs].freeze

    desc 'run-all-services', 'Execute all background services'
    def run_all_services()
      BackgroundServices.new.run
    end

    desc "run-service #{SERVICES.join('|')}", 'Execute only one background service'
    def run_service(service)
      raise "Invalid service #{service}" if SERVICES.exclude?(service)

      p "Running only one service: #{service}" # rubocop:disable Rails/Output
      sleep 10
    end
    # rubocop:enable Zammad/DetectTranslatableString
  end
end
