require 'spec_helper'

describe 'puppet_metrics_collector' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end

  context 'with default parameters' do
    it {
      execs = [
        'migrate /opt/puppetlabs/pe_metric_curl_cron_jobs directory',
        'puppet_metrics_collector_daemon_reload',
      ]
      execs.each { |exec| is_expected.to contain_exec(exec) }

      files = [
        '/opt/puppetlabs/puppet-metrics-collector',
        '/opt/puppetlabs/puppet-metrics-collector/config',
        '/opt/puppetlabs/puppet-metrics-collector/scripts',
        '/opt/puppetlabs/puppet-metrics-collector/scripts/create-metrics-archive',
        '/opt/puppetlabs/puppet-metrics-collector/scripts/json2timeseriesdb',
        '/opt/puppetlabs/puppet-metrics-collector/scripts/metrics_tidy',
        '/opt/puppetlabs/puppet-metrics-collector/scripts/pe_metrics.rb',
        '/opt/puppetlabs/puppet-metrics-collector/scripts/tk_metrics',
        '/opt/puppetlabs/puppet-metrics-collector/scripts/puma_metrics',
      ]
      files.each { |file| is_expected.to contain_file(file) }

      legacy_files = [
        '/opt/puppetlabs/puppet-metrics-collector/bin',
        '/opt/puppetlabs/bin/puppet-metrics-collector',
      ]
      legacy_files.each { |file| is_expected.to contain_file(file).with_ensure('absent') }

      ['ace', 'bolt', 'orchestrator', 'console', 'puppetdb', 'puppetserver'].each do |service|
        is_expected.to contain_class("puppet_metrics_collector::service::#{service}")
        is_expected.to contain_puppet_metrics_collector__collect(service)
        is_expected.to contain_puppet_metrics_collector__pe_metric(service)

        is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-tidy.service")
        is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-tidy.timer")
        is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.service")
        is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.timer")

        is_expected.to contain_service("puppet_#{service}-metrics.service")
        is_expected.to contain_service("puppet_#{service}-metrics.timer")
        is_expected.to contain_service("puppet_#{service}-tidy.service")
        is_expected.to contain_service("puppet_#{service}-tidy.timer")

        files = [
          "/opt/puppetlabs/puppet-metrics-collector/#{service}",
          "/opt/puppetlabs/puppet-metrics-collector/config/#{service}.yaml",
        ]
        files.each { |file| is_expected.to contain_file(file) }

        legacy_files = [
          "/opt/puppetlabs/puppet-metrics-collector/scripts/#{service}_config.yaml",
          "/opt/puppetlabs/puppet-metrics-collector/scripts/#{service}_metrics.sh",
          "/opt/puppetlabs/puppet-metrics-collector/scripts/#{service}_metrics",
          "/opt/puppetlabs/puppet-metrics-collector/scripts/#{service}_metrics_tidy",
        ]
        legacy_files.each { |file| is_expected.to contain_file(file).with_ensure('absent') }
      end

      legacy_crons = [
        'ace_metrics_tidy',
        'ace_metrics_collection',
        'activemq_metrics_collection',
        'activemq_metrics_tidy',
        'bolt_metrics_collection',
        'bolt_metrics_tidy',
        'console_metrics_collection',
        'console_metrics_tidy',
        'orchestrator_metrics_collection',
        'orchestrator_metrics_tidy',
        'puppetdb_metrics_collection',
        'puppetdb_metrics_tidy',
        'puppetserver_metrics_collection',
        'puppetserver_metrics_tidy',
      ]
      legacy_crons.each { |cron| is_expected.to contain_cron(cron).with_ensure('absent') }
    }
  end

  context 'when systemd is not the init provider' do
    let(:facts) { { puppet_metrics_collector: { have_systemd: false } } }

    it { is_expected.to contain_notify('systemd_provider_warning') }
  end

  context 'when puppet_metrics_collector::system is included first' do
    let(:pre_condition) { 'include puppet_metrics_collector::system' }

    it { is_expected.to compile }
  end

  context 'when puppet_metrics_collector::system is included last' do
    let(:post_condition) { 'include puppet_metrics_collector::system' }

    it { is_expected.to compile }
  end

  context 'when customizing the collection frequency' do
    let(:params) { { collection_frequency: 10 } }

    it {
      ['ace', 'bolt', 'orchestrator', 'console', 'puppetdb', 'puppetserver'].each do |service|
        is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.timer").with_content(%r{OnCalendar=.*0\/10})
      end
    }
  end
end
