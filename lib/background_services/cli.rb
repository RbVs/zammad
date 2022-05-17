# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  class Cli < Thor
    # rubocop:disable Zammad/DetectTranslatableString

    def self.exit_on_failure?
      # Signal to Thor API that failures should be reflected in the exit code.
      true
    end

    desc 'start', 'Execute background services.'
    def start
      BackgroundServices.new.run
    end

    def self.help(shell, subcommand = nil)
      super
      shell.say 'You can customize startup behaviour for the different background services with these command line options:'
      shell.say

      list = [
        ['Service', 'Set worker count', 'Max. workers', 'Disable this service'],
        ['-------', '----------------', '------------', '--------------------'],
      ]
      BackgroundServices.available_services.each do |service|
        service_name = service.name.demodulize
        env_prefix   = "ZAMMAD_#{service_name.underscore.upcase}"
        list.push [service_name, "#{env_prefix}_WORKERS", service.max_workers, "#{env_prefix}_DISABLE"]
      end
      shell.print_table(list, indent: 2)

    end

    # rubocop:enable Zammad/DetectTranslatableString
  end
end
