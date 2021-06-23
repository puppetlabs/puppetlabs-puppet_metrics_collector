require 'spec_helper_acceptance'

describe 'puppet_metrics_collector class' do
  context 'activates module default parameters' do
    it 'applies the class with default parameters' do
      pp = <<-MANIFEST
        include puppet_metrics_collector
        MANIFEST

      # Run it twice and test for idempotency
      idempotent_apply(pp)
    end
    describe 'check systemd fact' do
      it 'is true on all supported OS' do
        expect(host_inventory['facter']['puppet_metrics_collector']['have_systemd']).to eq true
      end
    end
    describe 'check puppet-metrics-collector directory' do
      it 'scripts folder exists' do
        file('/opt/puppetlabs/puppet-metrics-collector/scripts').should be_directory
      end
    end
  end
end
