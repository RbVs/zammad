# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class BackgroundServices
  class Cli < Thor
    # rubocop:disable Zammad/DetectTranslatableString

    SERVICES = BackgroundServices.available_services.index_by do |s|
      s.name.demodulize.underscore.dasherize
    end

    desc 'run-all-services', 'Execute all background services.'
    def run_all_services()
      BackgroundServices.new.run
    end

    desc "run-services #{SERVICES.keys.join('|')}", 'Execute the specified background service(s) (comma-separated).'
    def run_service(services_list)
      services = services_list.split(',').uniq
      services.each do |service|
        raise "Invalid service #{service}" if SERVICES.exclude?(service)
      end
      raise 'No service was specified.' if services.length.zero?

      BackgroundServices.new.run(services.map { |s| SERVICES[s] })
    end
    # rubocop:enable Zammad/DetectTranslatableString
  end
end
