require 'spec_helper_acceptance'

describe 'system class' do
  context 'sysstat not installed and not managed' do
    before(:all) do
      run_shell('puppet resource package sysstat ensure=absent')
      pp = <<-MANIFEST
          include puppet_metrics_collector::system
          MANIFEST
      # The notify makes this non idempotent
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      expect(apply_manifest(pp).exit_code).not_to eq(1)
    end

    context 'postgres timers are running' do
      it { expect(service('puppet_postgres-metrics.timer')).to be_running }
      it { expect(service('puppet_postgres-tidy.timer')).to be_running }
    end

    it 'creates tidy service file for postgres' do
      files = run_shell('ls /etc/systemd/system/puppet_postgres-tidy.service').stdout
      expect(files.split("\n")).not_to be_empty
    end

    it 'creates the service file for postgres' do
      files = run_shell('ls /etc/systemd/system/puppet_postgres-metrics.service').stdout
      expect(files.split("\n")).not_to be_empty
    end

    it 'sysstat package is not installed by default' do
      expect(package('sysstat')).not_to be_installed
    end

    it 'have_sysstat is false without the package installed' do
      expect(host_inventory['facter']['puppet_metrics_collector']['have_sysstat']).to eq false
    end
  end

  context 'sysstat installed and not managed' do
    before(:all) do
      run_shell('puppet resource package sysstat ensure=installed')
      pp = <<-MANIFEST
          include puppet_metrics_collector::system
          MANIFEST
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      expect(apply_manifest(pp).exit_code).not_to eq(1)
    end

    it 'system puppet_* metric services should be active or inactive' do
      run_shell('systemctl list-units --type=service | grep "puppet_system.*metrics"') do |r|
        expect(r.stdout).to match(%r{activ})
      end
    end

    context 'system timers are running' do
      it { expect(service('puppet_system_cpu-metrics.timer')).to be_running }
      it { expect(service('puppet_system_cpu-tidy.timer')).to be_running }
      it { expect(service('puppet_system_memory-metrics.timer')).to be_running }
      it { expect(service('puppet_system_memory-tidy.timer')).to be_running }
      it { expect(service('puppet_system_processes-metrics.timer')).to be_running }
      it { expect(service('puppet_system_processes-tidy.timer')).to be_running }
    end

    it 'creates system tidy services files' do
      files = run_shell('ls /etc/systemd/system/puppet_system*-tidy.service').stdout
      expect(files.split("\n").count).to eq(3)
    end
  end

  context 'managing sysstat' do
    before(:all) do
      pp = <<-MANIFEST
          class { 'puppet_metrics_collector::system':
            manage_sysstat => true,
          }
          MANIFEST
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      expect(apply_manifest(pp).exit_code).not_to eq(1)
    end

    it 'sysstat package is installed' do
      expect(package('sysstat')).to be_installed
    end

    it 'system puppet_* metric services should be active or inactive' do
      run_shell('systemctl list-units --type=service | grep "puppet_system.*metrics"') do |r|
        expect(r.stdout).to match(%r{activ})
      end
    end

    context 'system timers are running' do
      it { expect(service('puppet_system_cpu-metrics.timer')).to be_running }
      it { expect(service('puppet_system_cpu-tidy.timer')).to be_running }
      it { expect(service('puppet_system_memory-metrics.timer')).to be_running }
      it { expect(service('puppet_system_memory-tidy.timer')).to be_running }
      it { expect(service('puppet_system_processes-metrics.timer')).to be_running }
      it { expect(service('puppet_system_processes-tidy.timer')).to be_running }
    end

    it 'creates system tidy services files' do
      files = run_shell('ls /etc/systemd/system/puppet_system*-tidy.service').stdout
      expect(files.split("\n").count).to eq(3)
    end
  end
end
