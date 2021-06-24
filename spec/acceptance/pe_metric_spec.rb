require 'spec_helper_acceptance'

describe 'test default and system includes' do
  before(:all) do
    pp = <<-MANIFEST
        include puppet_metrics_collector
        include puppet_metrics_collector::system
        MANIFEST
    idempotent_apply(pp)
  end
  it 'all puppet_* metric services should be active or inactive' do
    run_shell('systemctl list-units --type=service | grep "puppet_.*metrics"') do |r|
      expect(r.stdout).to match(%r{activ})
    end
  end
  context 'all of the timers are running' do
    it { expect(service('puppet_ace-metrics.timer')).to be_running }
    it { expect(service('puppet_ace-tidy.timer')).to be_running }
    it { expect(service('puppet_bolt-metrics.timer')).to be_running }
    it { expect(service('puppet_bolt-tidy.timer')).to be_running }
    it { expect(service('puppet_orchestrator-metrics.timer')).to be_running }
    it { expect(service('puppet_orchestrator-tidy.timer')).to be_running }
    it { expect(service('puppet_postgres-metrics.timer')).to be_running }
    it { expect(service('puppet_postgres-tidy.timer')).to be_running }
    it { expect(service('puppet_puppetdb-metrics.timer')).to be_running }
    it { expect(service('puppet_puppetdb-tidy.timer')).to be_running }
    it { expect(service('puppet_puppetserver-metrics.timer')).to be_running }
    it { expect(service('puppet_puppetserver-tidy.timer')).to be_running }
    it { expect(service('puppet_system_cpu-metrics.timer')).to be_running }
    it { expect(service('puppet_system_cpu-tidy.timer')).to be_running }
    it { expect(service('puppet_system_memory-metrics.timer')).to be_running }
    it { expect(service('puppet_system_memory-tidy.timer')).to be_running }
    it { expect(service('puppet_system_processes-metrics.timer')).to be_running }
    it { expect(service('puppet_system_processes-tidy.timer')).to be_running }
  end
  it 'creates tidy services files' do
    files = run_shell('ls /etc/systemd/system/puppet_*-tidy.service').stdout
    expect(files.split("\n").count).to eq(9)
  end
  it 'creates the timer files' do
    files = run_shell('ls /etc/systemd/system/puppet_*-tidy.timer').stdout
    expect(files.split("\n").count).to eq(9)
  end
  it 'sysstat package is installed' do
    expect(package('sysstat')).to be_installed
  end

  describe file('/opt/puppetlabs/puppet-metrics-collector/puppetserver/127.0.0.1') do
    before(:each) { run_shell('systemctl start puppet_puppetserver-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell('ls /opt/puppetlabs/puppet-metrics-collector/puppetserver/127.0.0.1/*').stdout
      expect(files.split('\n')).not_to be_empty
    end
  end

  describe file('/opt/puppetlabs/puppet-metrics-collector/puppetdb/127.0.0.1') do
    before(:each) { run_shell('systemctl start puppet_puppetdb-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell('ls /opt/puppetlabs/puppet-metrics-collector/puppetdb/127.0.0.1/*').stdout
      expect(files.split('\n')).not_to be_empty
    end
  end

  describe file('/opt/puppetlabs/puppet-metrics-collector/orchestrator/127.0.0.1') do
    before(:each) { run_shell('systemctl start puppet_orchestrator-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell('ls /opt/puppetlabs/puppet-metrics-collector/orchestrator/127.0.0.1/*').stdout
      expect(files.split('\n')).not_to be_empty
    end
  end

  describe file('/opt/puppetlabs/puppet-metrics-collector/ace/127.0.0.1') do
    before(:each) { run_shell('systemctl start puppet_ace-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell('ls /opt/puppetlabs/puppet-metrics-collector/ace/127.0.0.1/*').stdout
      expect(files.split('\n')).not_to be_empty
    end
  end

  describe file('/opt/puppetlabs/puppet-metrics-collector/bolt/127.0.0.1') do
    before(:each) { run_shell('systemctl start puppet_bolt-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell('ls /opt/puppetlabs/puppet-metrics-collector/bolt/127.0.0.1/*').stdout
      expect(files.split('\n')).not_to be_empty
    end
  end
end
