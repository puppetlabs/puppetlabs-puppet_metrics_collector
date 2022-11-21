require 'spec_helper'

describe 'puppet_metrics_collector::system' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile

        case facts[:os]['family']
        when 'Debian'
          is_expected.to contain_class('puppet_metrics_collector::system').with(
            runuser_path: '/sbin/runuser',
          )
        else
          is_expected.to contain_class('puppet_metrics_collector::system').with(
            runuser_path: '/usr/sbin/runuser',
          )
        end
      }
    end
  end
  context 'with default parameters' do
    it { is_expected.not_to contain_package('sysstat') }
    it { is_expected.not_to contain_package('open-vm-tools') }
  end

  context 'with sysstat' do
    context 'already installed' do
      let(:pre_condition) { 'package{"sysstat": }' }
      let(:facts) { { puppet_metrics_collector: { have_sysstat: true, have_systemd: true } } }

      it { is_expected.to contain_class('puppet_metrics_collector::system::cpu') }
      it { is_expected.to contain_class('puppet_metrics_collector::system::memory') }
      it { is_expected.to contain_class('puppet_metrics_collector::system::processes') }
    end

    context 'not installed and managed' do
      let(:params) { { manage_sysstat: true } }
      let(:facts) { { puppet_metrics_collector: { have_sysstat: false, have_systemd: true } } }

      it { is_expected.to contain_package('sysstat') }
      it { is_expected.to contain_class('puppet_metrics_collector::system::cpu') }
      it { is_expected.to contain_class('puppet_metrics_collector::system::memory') }
      it { is_expected.to contain_class('puppet_metrics_collector::system::processes') }
    end

    context 'not installed and not managed' do
      it { is_expected.not_to contain_package('sysstat') }
      it { is_expected.not_to contain_class('puppet_metrics_collector::system::cpu') }
      it { is_expected.not_to contain_class('puppet_metrics_collector::system::memory') }
      it { is_expected.not_to contain_class('puppet_metrics_collector::system::processes') }
    end
  end
  context 'when the virtual fact does not report vmware' do
    let(:facts) { { virtual: 'physical' } }

    it { is_expected.not_to contain_class('puppet_metrics_collector::system::vmware') }
  end

  context 'when the virtual fact reports vmware' do
    let(:facts) { { virtual: 'vmware' } }

    it { is_expected.to contain_class('puppet_metrics_collector::system::vmware') }
    it { is_expected.not_to contain_package('open-vm-tools') }

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

    it { is_expected.to contain_service('puppet_postgres-metrics.timer').with_ensure('running') }
  end

  context 'when /opt/puppetlabs/server/bin/psql is absent' do
    let(:facts) { { puppet_metrics_collector: { have_pe_psql: false, have_systemd: true } } }

    it { is_expected.not_to contain_service('puppet_postgres-metrics.timer') }
  end

  context 'when metrics shipping is enabled' do
    let(:params) do
      {
        metrics_server_type: 'influxdb',
        metrics_server_db_name: 'puppet_metrics',
        metrics_server_hostname: 'influxdb.example'
      }
    end
    let(:facts) { { puppet_metrics_collector: { have_sysstat: true, have_systemd: true } } }

    it { is_expected.to contain_puppet_metrics_collector__collect('system_cpu').with_metrics_command(%r{--influx-db\s+puppet_metrics}) }
  end

  context 'when metrics shipping is enabled in puppet_metrics_collector' do
    let(:pre_condition) do
      <<-PRE_COND
      class {'puppet_metrics_collector':
        metrics_server_type => "influxdb",
        metrics_server_db_name => "puppet_metrics",
        metrics_server_hostname => "influxdb.example",
      }
      PRE_COND
    end
    let(:facts) { { puppet_metrics_collector: { have_sysstat: true, have_systemd: true } } }

    it { is_expected.to contain_puppet_metrics_collector__collect('system_cpu').with_metrics_command(%r{--influx-db\s+puppet_metrics}) }
  end

  context 'when metrics shipping is not enabled' do
    let(:params) do
      {
        metrics_server_db_name: 'puppet_metrics',
        metrics_server_hostname: 'influxdb.example'
      }
    end
    let(:facts) { { puppet_metrics_collector: { have_sysstat: true, have_systemd: true } } }

    it { is_expected.not_to contain_puppet_metrics_collector__collect('system_cpu').with_metrics_command(%r{--influx-db\s+puppet_metrics}) }
  end

  context 'when customizing the collection frequency' do
    let(:facts) do
      { puppet_metrics_collector: { have_vmware_tools: true, have_systemd: true, have_sysstat: true, have_pe_psql: true },
        virtual: 'vmware' }
    end
    let(:params) { { collection_frequency: 10 } }

    ['system_cpu', 'system_memory', 'system_processes', 'postgres', 'vmware'].each do |service|
      it { is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.timer").with_content(%r{OnCalendar=.*0\/10}) }
    end
  end
end
