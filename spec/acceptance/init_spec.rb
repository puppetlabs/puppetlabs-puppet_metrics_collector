require 'spec_helper_acceptance'

def have_systemd?
  host_inventory['facter']['puppet_metrics_collector']['have_systemd'] == 'true'
end

describe 'puppet_metrics_collector class' do
  context 'activates module default parameters' do
    it 'applies the class with default parameters' do
      pp = <<-MANIFEST
        include puppet_metrics_collector
        MANIFEST

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      idempotent_apply(pp)
    end
    describe 'check systemd fact' do
      it 'is true on all supported OS' do
        have_systemd?
      end
    end
  end
end
