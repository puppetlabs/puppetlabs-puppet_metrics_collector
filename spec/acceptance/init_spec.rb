require 'spec_helper_acceptance'

describe 'puppet_metrics_collector class' do
  context 'activates module default parameters' do
    it 'sets up crons + timers' do
      pp = <<-MANIFEST
        include puppet_metrics_collector
        MANIFEST

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      idempotent_apply(pp)
    end
  end
end
