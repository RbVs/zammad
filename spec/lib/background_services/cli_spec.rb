# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

RSpec.describe BackgroundServices::Cli do
  context 'when invoking scripts/background_services.rb via CLI' do

    context 'without arguments' do
      it 'shows a help screen' do
        expect { described_class.start([]) }.to output(%r{help \[COMMAND\]}).to_stdout
      end

      it 'returns success' do
        expect(described_class.start([])).to be_truthy
      end
    end

    def run_with_timeout(&block)
      # Stop after timeout and return true if everything was ok.
      Timeout.timeout(2.seconds, &block)
      raise 'Process ended unexpectedly.'
    rescue SystemExit
      # Convert SystemExit to a RuntimeError as otherwise rspec will shut down without an error.
      raise 'Process tried to shut down unexpectedly.'
    rescue Timeout::Error
      # Default case: process started fine and kept running, interrupted by timeout.
      true
    end

    context 'with wrong arguments' do
      it 'raises an error' do
        expect { run_with_timeout { described_class.start(['invalid-command-name']) } }.to raise_error(RuntimeError, 'Process tried to shut down unexpectedly.')
      end
    end

    context 'when running all services' do
      it 'starts scheduler correctly' do
        expect(run_with_timeout { described_class.start ['run-all-services'] }).to be(true)
      end
    end

    context 'when running only process-delayed-jobs' do
      it 'starts scheduler correctly' do
        expect(run_with_timeout { described_class.start %w[run-services process-delayed-jobs] }).to be(true)
      end
    end

    context 'when running only process-scheduled-jobs' do
      it 'starts scheduler correctly' do
        expect(run_with_timeout { described_class.start %w[run-services process-scheduled-jobs] }).to be(true)
      end
    end
  end
end
