require 'spec_helper'

describe 'puppet_metrics_collector::system' do
  context 'with default parameters' do
    it {
      is_expected.not_to contain_package('sysstat')
      is_expected.not_to contain_package('open-vm-tools')
    }
  end

  context 'with sysstat' do
    context 'already installed' do
      let(:pre_condition) { 'package{"sysstat": }' }
      let(:facts) { { puppet_metrics_collector: { have_sysstat: true, have_systemd: true } } }

      it {
        is_expected.not_to contain_class('puppet_metrics_collector::system::cpu')
        is_expected.not_to contain_class('puppet_metrics_collector::system::memory')
        is_expected.to contain_class('puppet_metrics_collector::system::sar')
        is_expected.to contain_class('puppet_metrics_collector::system::processes')
        is_expected.to contain_file('/opt/puppetlabs/puppet-metrics-collector/scripts/system_metrics')

        legacy_crons = [
          'system_cpu_metrics_collection',
          'system_cpu_metrics_tidy',
          'system_processes_metrics_collection',
          'system_processes_metrics_tidy',
          'system_memory_metrics_collection',
          'system_memory_metrics_tidy',
        ]
        legacy_crons.each { |cron| is_expected.to contain_cron(cron).with_ensure('absent') }

        ['system_cpu', 'system_processes'].each do |service|
          is_expected.to contain_puppet_metrics_collector__collect(service)
          is_expected.to contain_puppet_metrics_collector__sar_metric(service)

          is_expected.to contain_file("/opt/puppetlabs/puppet-metrics-collector/#{service}")

          is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-tidy.service")
          is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-tidy.timer")
          is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.service")
          is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.timer")

          is_expected.to contain_service("puppet_#{service}-metrics.service")
          is_expected.to contain_service("puppet_#{service}-metrics.timer")
          is_expected.to contain_service("puppet_#{service}-tidy.service")
          is_expected.to contain_service("puppet_#{service}-tidy.timer")
        end

        legacy_files = [
          '/opt/puppetlabs/puppet-metrics-collector/scripts/system_processes_metrics_tidy',
          '/opt/puppetlabs/puppet-metrics-collector/scripts/system_memory_metrics_tidy',
          '/opt/puppetlabs/puppet-metrics-collector/scripts/system_cpu_metrics_tidy',
          '/opt/puppetlabs/puppet-metrics-collector/scripts/generate_system_metrics',
        ]
        legacy_files.each { |file| is_expected.to contain_file(file).with_ensure('absent') }

        ['system_memory'].each do |service|
          is_expected.to contain_puppet_metrics_collector__sar_metric(service).with_metric_ensure('absent')
          is_expected.to contain_puppet_metrics_collector__collect(service).with_ensure('absent')

          is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-tidy.service").with_ensure('absent')
          is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-tidy.timer").with_ensure('absent')
          is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.service").with_ensure('absent')
          is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.timer").with_ensure('absent')
          is_expected.to contain_file("/opt/puppetlabs/puppet-metrics-collector/#{service}").with_ensure('absent')

          is_expected.to contain_service("puppet_#{service}-metrics.service").with_ensure('stopped')
          is_expected.to contain_service("puppet_#{service}-metrics.timer").with_ensure('stopped')
          is_expected.to contain_service("puppet_#{service}-tidy.service").with_ensure('stopped')
          is_expected.to contain_service("puppet_#{service}-tidy.timer").with_ensure('stopped')
        end
      }
    end

    context 'not installed and managed' do
      let(:params) { { manage_sysstat: true } }
      let(:facts) { { puppet_metrics_collector: { have_sysstat: false, have_systemd: true } } }

      it { is_expected.to contain_package('sysstat') }
      it { is_expected.not_to contain_class('puppet_metrics_collector::system::cpu') }
      it { is_expected.not_to contain_class('puppet_metrics_collector::system::memory') }
      it { is_expected.to contain_class('puppet_metrics_collector::system::sar') }
      it { is_expected.to contain_class('puppet_metrics_collector::system::processes') }
    end

    context 'not installed and not managed' do
      it { is_expected.not_to contain_package('sysstat') }
      it { is_expected.not_to contain_class('puppet_metrics_collector::system::cpu') }
      it { is_expected.not_to contain_class('puppet_metrics_collector::system::memory') }
      it { is_expected.not_to contain_class('puppet_metrics_collector::system::sar') }
      it { is_expected.not_to contain_class('puppet_metrics_collector::system::processes') }
    end
  end
  context 'when the virtual fact does not report vmware' do
    let(:facts) { { virtual: 'physical' } }

    it { is_expected.not_to contain_class('puppet_metrics_collector::system::vmware') }
  end

  context 'when the virtual fact reports vmware' do
    let(:facts) { { virtual: 'vmware' } }

    it {
      is_expected.to contain_class('puppet_metrics_collector::system::vmware')
      is_expected.not_to contain_package('open-vm-tools')

      is_expected.to contain_exec('puppet_metrics_collector_system_daemon_reload')

      legacy_crons = [
        'vmware_metrics_collection',
        'vmware_metrics_tidy',
      ]
      legacy_crons.each { |cron| is_expected.to contain_cron(cron).with_ensure('absent') }

      is_expected.to contain_puppet_metrics_collector__collect('vmware')

      is_expected.to contain_file('/opt/puppetlabs/puppet-metrics-collector/vmware')
      is_expected.to contain_file('/opt/puppetlabs/puppet-metrics-collector/scripts/vmware_metrics')

      is_expected.to contain_file('/etc/systemd/system/puppet_vmware-tidy.service')
      is_expected.to contain_file('/etc/systemd/system/puppet_vmware-tidy.timer')
      is_expected.to contain_file('/etc/systemd/system/puppet_vmware-metrics.service')
      is_expected.to contain_file('/etc/systemd/system/puppet_vmware-metrics.timer')

      is_expected.to contain_service('puppet_vmware-metrics.service')
      is_expected.to contain_service('puppet_vmware-metrics.timer')
      is_expected.to contain_service('puppet_vmware-tidy.service')
      is_expected.to contain_service('puppet_vmware-tidy.timer')
    }

    context 'when management of VMware Tools is enabled' do
      let(:params) { { manage_vmware_tools: true, vmware_tools_pkg: 'foo-tools' } }

      it { is_expected.to contain_package('foo-tools').with_ensure('present') }
    end

    context 'when vmware-toolbox-cmd is present on the PATH' do
      let(:facts) { super().merge(puppet_metrics_collector: { have_vmware_tools: true, have_systemd: true }) }

      it { is_expected.to contain_service('puppet_vmware-metrics.timer').with_ensure('running') }
    end

    context 'when vmware-toolbox-cmd is not present on the PATH' do
      let(:facts) { super().merge(puppet_metrics_collector: { have_vmware_tools: false, have_systemd: true }) }

      it { is_expected.to contain_notify('vmware_tools_warning') }
    end
  end

  context 'when /opt/puppetlabs/server/bin/psql is present' do
    let(:facts) { { puppet_metrics_collector: { have_pe_psql: true, have_systemd: true } } }

    it {
      is_expected.to contain_class('puppet_metrics_collector::system::postgres')
      is_expected.to contain_puppet_metrics_collector__collect('postgres')

      is_expected.to contain_file('/opt/puppetlabs/puppet-metrics-collector/postgres')
      is_expected.to contain_file('/opt/puppetlabs/puppet-metrics-collector/scripts/psql_metrics')

      is_expected.to contain_file('/etc/systemd/system/puppet_postgres-tidy.service')
      is_expected.to contain_file('/etc/systemd/system/puppet_postgres-tidy.timer')
      is_expected.to contain_file('/etc/systemd/system/puppet_postgres-metrics.service')
      is_expected.to contain_file('/etc/systemd/system/puppet_postgres-metrics.timer')

      is_expected.to contain_service('puppet_postgres-metrics.service')
      is_expected.to contain_service('puppet_postgres-metrics.timer')
      is_expected.to contain_service('puppet_postgres-tidy.service')
      is_expected.to contain_service('puppet_postgres-tidy.timer')

      legacy_crons = [
        'postgres_metrics_collection',
        'postgres_metrics_tidy',
      ]
      legacy_crons.each { |cron| is_expected.to contain_cron(cron).with_ensure('absent') }
    }
  end

  context 'when /opt/puppetlabs/server/bin/psql is absent' do
    let(:facts) { { puppet_metrics_collector: { have_pe_psql: false, have_systemd: true } } }

    it { is_expected.not_to contain_service('puppet_postgres-metrics.timer') }
  end

  context 'when metrics shipping is enabled' do
    let(:params) do
      {
        metrics_server_type: 'splunk_hec',
      }
    end
    let(:facts) { { puppet_metrics_collector: { have_sysstat: true, have_systemd: true } } }

    it { is_expected.to contain_puppet_metrics_collector__collect('system_cpu').with_metrics_command(%r{/opt/puppetlabs/bin/puppet splunk_hec --sourcetype puppet:metrics --pe_metrics}) }
  end

  context 'when metrics shipping is enabled in puppet_metrics_collector' do
    let(:pre_condition) do
      <<-PRE_COND
      class {'puppet_metrics_collector':
        metrics_server_type => "splunk_hec",
      }
      PRE_COND
    end
    let(:facts) { { puppet_metrics_collector: { have_sysstat: true, have_systemd: true } } }

    it {
      is_expected.to contain_puppet_metrics_collector__collect('system_cpu').with_metrics_command(
        %r{/opt/puppetlabs/bin/puppet splunk_hec --sourcetype puppet:metrics --pe_metrics},
      )
    }
  end

  context 'when metrics shipping is not enabled' do
    let(:facts) { { puppet_metrics_collector: { have_sysstat: true, have_systemd: true } } }

    it {
      is_expected.not_to contain_puppet_metrics_collector__collect('system_cpu').with_metrics_command(
        %r{/opt/puppetlabs/bin/puppet splunk_hec --sourcetype puppet:metrics --pe_metrics},
      )
    }
  end

  context 'when setting deprecated parameters' do
    let(:facts) { { puppet_metrics_collector: { have_sysstat: true, have_systemd: true } } }
    let(:params) { { metrics_server_type: 'influxdb' } }

    it {
      is_expected.to contain_puppet_metrics_collector__deprecated_parameter('puppet_metrics_collector::system::metrics_server_type')
      is_expected.to contain_notify('Invalid value for puppet_metrics_collector::system::metrics_server_type')
    }
  end

  context 'when customizing the collection frequency' do
    let(:facts) do
      { puppet_metrics_collector: { have_vmware_tools: true, have_systemd: true, have_sysstat: true, have_pe_psql: true },
        virtual: 'vmware' }
    end
    let(:params) { { collection_frequency: 10 } }

    ['system_cpu', 'system_processes', 'postgres', 'vmware'].each do |service|
      it { is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.timer").with_content(%r{OnCalendar=.*0\/10}) }
    end
  end
end
