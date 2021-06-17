# Collect Metrics
class puppet_metrics_collector (
  String                  $puppetserver_metrics_ensure = 'present',
  String                  $output_dir                  = '/opt/puppetlabs/puppet-metrics-collector',
  Integer                 $collection_frequency        = 5,
  Integer                 $retention_days              = 90,
  Array[String]           $puppetserver_hosts          = puppet_metrics_collector::hosts_with_pe_profile('master'),
  Integer                 $puppetserver_port           = 8140,
  String                  $puppetdb_metrics_ensure     = 'present',
  Array[String]           $puppetdb_hosts              = puppet_metrics_collector::hosts_with_pe_profile('puppetdb'),
  Integer                 $puppetdb_port               = 8081,
  String                  $orchestrator_metrics_ensure = 'present',
  Array[String]           $orchestrator_hosts          = puppet_metrics_collector::hosts_with_pe_profile('orchestrator'),
  Integer                 $orchestrator_port           = 8143,
  String                  $ace_metrics_ensure          = 'present',
  Array[String]           $ace_hosts                   = puppet_metrics_collector::hosts_with_pe_profile('ace_server'),
  Integer                 $ace_port                    = 44633,
  String                  $bolt_metrics_ensure         = 'present',
  Array[String]           $bolt_hosts                  = puppet_metrics_collector::hosts_with_pe_profile('bolt_server'),
  Integer                 $bolt_port                   = 62658,
  # Collection of ActiveMQ metrics has been removed, but the parameters are left to avoid breaking upgrades
  String                  $activemq_metrics_ensure     = 'absent',
  Array[String]           $activemq_hosts              = [],
  Integer                 $activemq_port               = 8161,
  Optional[String]        $override_metrics_command    = undef,
  Optional[Array[String]] $puppetserver_excludes       = undef,
  Optional[Array[String]] $puppetdb_excludes           = undef,
  Optional[Array[String]] $orchestrator_excludes       = undef,
  Optional[Array[String]] $ace_excludes                = undef,
  Optional[Array[String]] $bolt_excludes               = undef,
  Optional[Array[String]] $activemq_excludes           = undef,
  Optional[Enum['influxdb', 'graphite', 'splunk_hec']] $metrics_server_type = undef,
  Optional[String]        $metrics_server_hostname     = undef,
  Optional[Integer]       $metrics_server_port         = undef,
  Optional[String]        $metrics_server_db_name      = undef,
) {
  $config_dir  = "${output_dir}/config"
  $scripts_dir = "${output_dir}/scripts"

  if $facts.dig('puppet_metrics_collector', 'have_systemd') {
    # If the puppet_metrics_collector::system class is evaluted first,
    # File[$output_dir] will already be defined along with common scripts.
    if !defined(File[$output_dir]) {
      file { [$output_dir, $scripts_dir]:
        ensure => directory,
      }

      file { "${scripts_dir}/create-metrics-archive":
        ensure => file,
        mode   => '0755',
        source => 'puppet:///modules/puppet_metrics_collector/create-metrics-archive'
      }

      file { "${scripts_dir}/metrics_tidy":
        ensure => file,
        mode   => '0744',
        source => 'puppet:///modules/puppet_metrics_collector/metrics_tidy'
      }
    }

    file { $config_dir:
      ensure => directory,
    }

    file { "${scripts_dir}/json2timeseriesdb" :
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/json2timeseriesdb'
    }

    file { "${scripts_dir}/pe_metrics.rb" :
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/pe_metrics.rb'
    }

    file { "${scripts_dir}/puma_metrics" :
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/puma_metrics'
    }

    file { "${scripts_dir}/tk_metrics" :
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/tk_metrics'
    }

    exec { 'puppet_metrics_collector_daemon_reload':
      command     => 'systemctl daemon-reload',
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
    }

    include puppet_metrics_collector::service::puppetserver
    include puppet_metrics_collector::service::puppetdb
    include puppet_metrics_collector::service::orchestrator
    include puppet_metrics_collector::service::ace
    include puppet_metrics_collector::service::bolt

    # LEGACY CLEANUP

    # Clean up old metrics directories created by the module before it was renamed.

    $legacy_dir      = '/opt/puppetlabs/pe_metric_curl_cron_jobs'
    $safe_output_dir = shellquote($output_dir)

    exec { "migrate ${legacy_dir} directory":
      path    => '/bin:/usr/bin',
      command => "mv ${legacy_dir} ${safe_output_dir}",
      onlyif  => "[ ! -e ${safe_output_dir} -a -e ${legacy_dir} ]",
      before  => File[$output_dir],
    }

    $legacy_files = [
      '/opt/puppetlabs/bin/puppet-metrics-collector',
      '/opt/puppetlabs/puppet-metrics-collector/bin',
    ]

    file { $legacy_files :
      ensure => absent,
      force  => true,
    }

    # Manual cleanup of deprecated AMQ jobs
    cron { ['activemq_metrics_collection', 'activemq_metrics_tidy']:
      ensure => absent,
    }
  } else {
    notify { 'systemd_provider_warning':
      message  => 'This module only works with systemd as the provider',
      loglevel => warning,
    }
  }
}
