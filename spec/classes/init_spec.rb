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

  context 'when setting deprecated parameters' do
    let(:params) do
      {
        metrics_server_type: 'influxdb', metrics_server_hostname: 'foo', metrics_server_port: 1234, metrics_server_db_name: 'bar'
      }
    end

    it {
      is_expected.to contain_puppet_metrics_collector__deprecated_parameter('puppet_metrics_collector::metrics_server_type')
      is_expected.to contain_puppet_metrics_collector__deprecated_parameter('puppet_metrics_collector::metrics_server_hostname')
      is_expected.to contain_puppet_metrics_collector__deprecated_parameter('puppet_metrics_collector::metrics_server_port')
      is_expected.to contain_puppet_metrics_collector__deprecated_parameter('puppet_metrics_collector::metrics_server_db_name')
      is_expected.to contain_notify('Invalid value for puppet_metrics_collector::metrics_server_type')
      is_expected.to contain_notify('puppet_metrics_collector::metrics_server_db_name is deprecated')
      is_expected.to contain_notify('puppet_metrics_collector::metrics_server_hostname is deprecated')
      is_expected.to contain_notify('puppet_metrics_collector::metrics_server_port is deprecated')

      ['ace', 'bolt', 'orchestrator', 'console', 'puppetdb', 'puppetserver'].each do |service|
        is_expected.to contain_puppet_metrics_collector__pe_metric(service).with_metrics_server_type(nil)
        is_expected.to contain_notify("Invalid value for puppet_metrics_collector::service::#{service}::metrics_server_type")
        is_expected.to contain_notify("puppet_metrics_collector::service::#{service}::metrics_server_db_name is deprecated")
        is_expected.to contain_notify("puppet_metrics_collector::service::#{service}::metrics_server_hostname is deprecated")
        is_expected.to contain_notify("puppet_metrics_collector::service::#{service}::metrics_server_port is deprecated")

        is_expected.to contain_puppet_metrics_collector__deprecated_parameter("puppet_metrics_collector::service::#{service}::metrics_server_type")
        is_expected.to contain_puppet_metrics_collector__deprecated_parameter("puppet_metrics_collector::service::#{service}::metrics_server_hostname")
        is_expected.to contain_puppet_metrics_collector__deprecated_parameter("puppet_metrics_collector::service::#{service}::metrics_server_port")
        is_expected.to contain_puppet_metrics_collector__deprecated_parameter("puppet_metrics_collector::service::#{service}::metrics_server_db_name")
      end
    }
  end

  context 'when shipping to splunk' do
    let(:params) { { metrics_server_type: 'splunk_hec' } }

    it {
      ['ace', 'bolt', 'orchestrator', 'console', 'puppetdb', 'puppetserver'].each do |service|
        is_expected.to contain_puppet_metrics_collector__pe_metric(service).with_metrics_server_type('splunk_hec')
      end
    }
  end

  context 'when puppetdb_hosts is a normal (non-loopback) host list' do
    let(:params) { { puppetdb_hosts: ['puppetdb.example.com'] } }

    it { is_expected.to contain_puppet_metrics_collector__pe_metric('puppetdb').with_metrics_port(8081) }
    it { is_expected.to contain_puppet_metrics_collector__pe_metric('puppetdb').with_ssl(true) }
  end

  context 'when puppetdb_hosts resolves to the loopback address' do
    # Matches the "Configuration for Distributed Metrics Collection" pattern documented
    # in README.md, where a PuppetDB host is classified directly with
    # puppetdb_hosts => ['127.0.0.1'] to collect its own metrics over loopback.
    let(:params) { { puppetdb_hosts: ['127.0.0.1'] } }

    it 'always uses the SSL API port for PuppetDB metrics, never substituting the plaintext port' do
      is_expected.to contain_puppet_metrics_collector__pe_metric('puppetdb').with_metrics_port(8081)
    end

    it 'always reports ssl => true, since collection is always over HTTPS regardless of $hosts' do
      is_expected.to contain_puppet_metrics_collector__pe_metric('puppetdb').with_ssl(true)
    end
  end

  context 'when an explicit non-default puppetdb_port is set alongside the loopback address' do
    # This does not exercise the removed port-substitution branch -- that branch only ever
    # fired when $port was left at its default (8081). It documents that a custom port
    # always passes through unchanged, regardless of $hosts.
    let(:params) { { puppetdb_hosts: ['127.0.0.1'], puppetdb_port: 9999 } }

    it { is_expected.to contain_puppet_metrics_collector__pe_metric('puppetdb').with_metrics_port(9999) }
  end
end
