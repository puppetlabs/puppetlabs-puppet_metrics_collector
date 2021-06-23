require 'spec_helper_acceptance'

describe 'test default and system includes' do
  before(:all) do
    pp = <<-MANIFEST
        include puppet_metrics_collector
        include puppet_metrics_collector::system
        MANIFEST
    idempotent_apply(pp)
  end
  it 'sets all puppet_* metric services to be active' do
    run_shell('systemctl list-units --type=service | grep "puppet_.*metrics"') do |r|
      puts r.stdout
      expect(r.stdout).to match(%r{activ})
    end
  end
  it 'check for the tidy services files' do
    files = run_shell('ls /etc/systemd/system/puppet_*-tidy.service').stdout
    expect(files.split("\n").count).to eq(9)
  end
  it 'check for the timer files' do
    files = run_shell('ls /etc/systemd/system/puppet_*-tidy.timer').stdout
    expect(files.split("\n").count).to eq(9)
  end
  it 'checks if sysstat package is installed' do
    expect(package('sysstat')).to be_installed
  end
end
