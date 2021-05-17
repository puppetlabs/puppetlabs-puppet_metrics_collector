require 'spec_helper'

describe 'puppet_metrics_collector::pe_metric' do
  let(:title) { 'test-service' }
  let(:params) do
    { metrics_port: 9000 }
  end
  # This define has an undeclared dependency on the main
  # puppet_metrics_collector class.
  let(:pre_condition) { 'include puppet_metrics_collector' }

  it 'compiles with minimal parameters set' do
    expect(subject).to compile
  end

  describe 'remote metric collection' do
    it 'is disabled by default due to CVE-2020-7943' do
      expect(subject).to contain_file('/opt/puppetlabs/puppet-metrics-collector/config/test-service.yaml').with_content(%r{remote_metrics_enabled: false})
    end

    context 'when the PE version is 2019.8.5 or newer' do
      let(:facts) do
        { pe_server_version: '2019.8.5' }
      end

      it 'is enabled by default' do
        expect(subject).to contain_file('/opt/puppetlabs/puppet-metrics-collector/config/test-service.yaml').with_content(%r{remote_metrics_enabled: true})
      end
    end

    context 'when the PE version is 2019.8.4 or older' do
      let(:facts) do
        { pe_server_version: '2019.8.4' }
      end

      it 'is disabled by default' do
        expect(subject).to contain_file('/opt/puppetlabs/puppet-metrics-collector/config/test-service.yaml').with_content(%r{remote_metrics_enabled: false})
      end
    end
  end
end
