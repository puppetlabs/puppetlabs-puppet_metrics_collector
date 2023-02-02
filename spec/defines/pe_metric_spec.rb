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

  context 'with default parameters' do
    it {
      is_expected.to contain_service('puppet_test-service-metrics.timer').with_ensure('running')
      is_expected.to contain_service('puppet_test-service-metrics.service')

      is_expected.to contain_service('puppet_test-service-tidy.timer').with_ensure('running')
      is_expected.to contain_service('puppet_test-service-tidy.service')

      is_expected.to contain_puppet_metrics_collector__collect('test-service')

      files = [
        '/opt/puppetlabs/puppet-metrics-collector/scripts/test-service_config.yaml',
        '/opt/puppetlabs/puppet-metrics-collector/scripts/test-service_metrics.sh',
        '/opt/puppetlabs/puppet-metrics-collector/scripts/test-service_metrics',
        '/opt/puppetlabs/puppet-metrics-collector/scripts/test-service_metrics_tidy',
        '/opt/puppetlabs/puppet-metrics-collector/test-service',
        '/opt/puppetlabs/puppet-metrics-collector/config/test-service.yaml',
        '/etc/systemd/system/puppet_test-service-metrics.service',
        '/etc/systemd/system/puppet_test-service-tidy.service',
        '/etc/systemd/system/puppet_test-service-tidy.timer',

      ]
      files.each { |file| is_expected.to contain_file(file) }

      is_expected.to contain_cron('test-service_metrics_collection').with_ensure('absent')
      is_expected.to contain_cron('test-service_metrics_tidy').with_ensure('absent')
    }
  end

  context 'when not capturing metrics' do
    let(:params) { super().merge({ metric_ensure: 'absent' }) }

    it { is_expected.to contain_service('puppet_test-service-metrics.timer').with_ensure('stopped') }
  end

  context 'when customizing collection frequency' do
    let(:params) { super().merge({ cron_minute: '0/12' }) }

    it { is_expected.to contain_file('/etc/systemd/system/puppet_test-service-metrics.timer').with_content(%r{OnCalendar=.*0\/12}) }
  end
end
