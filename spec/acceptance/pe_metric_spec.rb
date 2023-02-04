require 'spec_helper_acceptance'

certname = host_inventory['fqdn']
describe 'default includes' do
  before(:all) do
    pp = <<-MANIFEST
        include puppet_metrics_collector
        MANIFEST
    idempotent_apply(pp)
  end

  context 'all of the timers are running' do
    it { expect(service('puppet_ace-metrics.timer')).to be_running }
    it { expect(service('puppet_ace-tidy.timer')).to be_running }
    it { expect(service('puppet_bolt-metrics.timer')).to be_running }
    it { expect(service('puppet_bolt-tidy.timer')).to be_running }
    it { expect(service('puppet_orchestrator-metrics.timer')).to be_running }
    it { expect(service('puppet_orchestrator-tidy.timer')).to be_running }
    it { expect(service('puppet_console-metrics.timer')).to be_running }
    it { expect(service('puppet_console-tidy.timer')).to be_running }
    it { expect(service('puppet_puppetdb-metrics.timer')).to be_running }
    it { expect(service('puppet_puppetdb-tidy.timer')).to be_running }
    it { expect(service('puppet_puppetserver-metrics.timer')).to be_running }
    it { expect(service('puppet_puppetserver-tidy.timer')).to be_running }
  end

  it 'creates tidy services files' do
    files = run_shell('ls /etc/systemd/system/puppet_*-tidy.service').stdout
    expect(files.split("\n").count).to eq(6)
  end

  it 'creates the timer files' do
    files = run_shell('ls /etc/systemd/system/puppet_*-tidy.timer').stdout
    expect(files.split("\n").count).to eq(6)
  end

  describe file("/opt/puppetlabs/puppet-metrics-collector/puppetserver/#{certname}") do
    before(:each) { run_shell('systemctl start puppet_puppetserver-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell("ls /opt/puppetlabs/puppet-metrics-collector/puppetserver/#{certname}/*").stdout
      expect(files.split('\n')).not_to be_empty
    end
  end

  describe file("/opt/puppetlabs/puppet-metrics-collector/puppetdb/#{certname}") do
    before(:each) { run_shell('systemctl start puppet_puppetdb-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell("ls /opt/puppetlabs/puppet-metrics-collector/puppetdb/#{certname}/*").stdout
      expect(files.split('\n')).not_to be_empty
    end
  end

  describe file("/opt/puppetlabs/puppet-metrics-collector/orchestrator/#{certname}") do
    before(:each) { run_shell('systemctl start puppet_orchestrator-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell("ls /opt/puppetlabs/puppet-metrics-collector/orchestrator/#{certname}/*").stdout
      expect(files.split('\n')).not_to be_empty
    end
  end

  describe file("/opt/puppetlabs/puppet-metrics-collector/console/#{certname}") do
    before(:each) { run_shell('systemctl start puppet_console-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell("ls /opt/puppetlabs/puppet-metrics-collector/console/#{certname}/*").stdout
      expect(files.split('\n')).not_to be_empty
    end
  end

  describe file("/opt/puppetlabs/puppet-metrics-collector/ace/#{certname}") do
    before(:each) { run_shell('systemctl start puppet_ace-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell("ls /opt/puppetlabs/puppet-metrics-collector/ace/#{certname}/*").stdout
      expect(files.split('\n')).not_to be_empty
    end
  end

  describe file("/opt/puppetlabs/puppet-metrics-collector/bolt/#{certname}") do
    before(:each) { run_shell('systemctl start puppet_bolt-metrics.service') }

    it { is_expected.to be_directory }
    it 'contains metric files' do
      files = run_shell("ls /opt/puppetlabs/puppet-metrics-collector/bolt/#{certname}/*").stdout
      expect(files.split('\n')).not_to be_empty
    end
  end
end
