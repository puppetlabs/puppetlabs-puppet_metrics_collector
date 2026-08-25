require 'spec_helper_acceptance'
require 'json'
require 'shellwords'

shared_examples 'system metrics collection' do
  # TODO: PE-46010 -- these block for the full collection_frequency window
  # (~5 real minutes each) since sar/pidstat poll for that long before
  # writing output; invoke system_metrics directly instead of via systemd
  # to cut this down without touching timer state.
  context 'system_cpu metrics collection' do
    before(:all) do
      run_shell('rm -rf /opt/puppetlabs/puppet-metrics-collector/system_cpu/*')

      # system_metrics writes its output file before exiting non-zero on a
      # sar exec failure, so let the (Type=oneshot) service exit non-zero
      # here rather than having run_shell raise, and assert on the file's
      # 'error' key instead -- that surfaces the actual sar failure message
      # instead of a bare "systemctl start" exit-1.
      run_shell('systemctl start puppet_system_cpu-metrics.service', expect_failures: true)
    end

    it 'records cpu utilization stats' do
      metrics_file = run_shell(
        "find /opt/puppetlabs/puppet-metrics-collector/system_cpu -type f -name '*.json' | sort | tail -1",
      ).stdout.strip
      expect(metrics_file).not_to be_empty

      metrics = JSON.parse(run_shell("cat #{Shellwords.escape(metrics_file)}").stdout)
      servers = metrics['servers']
      expect(servers.size).to eq(1)
      system_cpu = servers.values.first['system_cpu']

      # A broken sar run (e.g. missing binary, permission error) reports a
      # Hash with an 'error' key instead of the expected array of {name,
      # value} stat pairs -- check the shape first so a regression surfaces
      # the sar failure message via this assertion's own failure output.
      expect(system_cpu).to be_an(Array)
      expect(system_cpu.find { |stat| stat['name'] == '%idle' }).not_to be_nil
    end
  end

  context 'system_processes metrics collection' do
    before(:all) do
      run_shell('rm -rf /opt/puppetlabs/puppet-metrics-collector/system_processes/*')

      # Same rationale as system_cpu above: let a pidstat/ps exec failure
      # exit non-zero here so the assertions below can surface the file's
      # 'error' key instead of a bare "systemctl start" exit-1.
      run_shell('systemctl start puppet_system_processes-metrics.service', expect_failures: true)
    end

    it 'records pidstat data for a known-running PE service' do
      metrics_file = run_shell(
        "find /opt/puppetlabs/puppet-metrics-collector/system_processes -type f -name '*.json' | sort | tail -1",
      ).stdout.strip
      expect(metrics_file).not_to be_empty

      metrics = JSON.parse(run_shell("cat #{Shellwords.escape(metrics_file)}").stdout)
      servers = metrics['servers']
      expect(servers.size).to eq(1)
      system_processes = servers.values.first['system_processes']

      # A failed ps/pidstat run reports a Hash with an 'error' key; a host
      # with no matched processes reports a 'warning' key instead of
      # per-process data -- either shape would slip past a bare
      # timer.be_running check, so assert on real puppetserver data.
      expect(system_processes).to be_a(Hash)
      expect(system_processes['error']).to be_nil
      expect(system_processes['warning']).to be_nil
      puppetserver_stats = system_processes['puppetserver']
      expect(puppetserver_stats).not_to be_nil
      expect(puppetserver_stats['command_pidstat']).to eq('java')
    end
  end
end

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

    context 'postgres metrics collection' do
      before(:all) do
        run_shell('rm -rf /opt/puppetlabs/puppet-metrics-collector/postgres/*')

        # psql_metrics writes its output file before checking for query
        # errors, so let the (Type=oneshot) service exit non-zero here rather
        # than having run_shell raise, and assert on the file's 'error' key
        # instead -- that surfaces the actual psql failure message instead of
        # a bare "systemctl start" exit-1.
        run_shell('systemctl start puppet_postgres-metrics.service', expect_failures: true)
      end

      it 'records checkpoint stats for the running postgres version' do
        # The output directory is named after the host's `hostname`, which is
        # not necessarily the certname used by the other metrics services.
        # Filenames are UTC timestamps, so `sort` deterministically picks the
        # newest if a timer-triggered run drops a file alongside ours; `tail
        # -1` guards against `find` returning more than one match.
        metrics_file = run_shell(
          "find /opt/puppetlabs/puppet-metrics-collector/postgres -type f -name '*.json' | sort | tail -1",
        ).stdout.strip
        expect(metrics_file).not_to be_empty

        metrics = JSON.parse(run_shell("cat #{Shellwords.escape(metrics_file)}").stdout)
        postgres = metrics['servers'].values.first['postgres']

        # A failed query is reported under 'error' and its key is left out of
        # the result entirely, so assert on 'error' first to get a readable
        # failure that includes the psql message.
        expect(postgres['error']).to be_nil
        expect(postgres['checkpoints']['checkpoints_timed']).not_to be_nil
      end
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

    context 'system timers are running' do
      it { expect(service('puppet_system_cpu-metrics.timer')).to be_running }
      it { expect(service('puppet_system_cpu-tidy.timer')).to be_running }
      it { expect(service('puppet_system_processes-metrics.timer')).to be_running }
      it { expect(service('puppet_system_processes-tidy.timer')).to be_running }
    end

    it 'creates system tidy services files' do
      expect(run_shell('ls /etc/systemd/system/puppet_system_cpu-tidy.service').exit_code).to eq(0)
      expect(run_shell('ls /etc/systemd/system/puppet_system_processes-tidy.service').exit_code).to eq(0)
    end

    include_examples 'system metrics collection'
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

    context 'system timers are running' do
      it { expect(service('puppet_system_cpu-metrics.timer')).to be_running }
      it { expect(service('puppet_system_cpu-tidy.timer')).to be_running }
      it { expect(service('puppet_system_processes-metrics.timer')).to be_running }
      it { expect(service('puppet_system_processes-tidy.timer')).to be_running }
    end

    it 'creates system tidy services files' do
      expect(run_shell('ls /etc/systemd/system/puppet_system_cpu-tidy.service').exit_code).to eq(0)
      expect(run_shell('ls /etc/systemd/system/puppet_system_processes-tidy.service').exit_code).to eq(0)
    end

    include_examples 'system metrics collection'
  end
end
