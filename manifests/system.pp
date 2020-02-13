# Collect System Metrics
class puppet_metrics_collector::system (
  String  $system_metrics_ensure     = 'present',
  String  $output_dir                = '/opt/puppetlabs/puppet-metrics-collector',
  Integer $collection_frequency      = 5, # minutes
  Integer $retention_days            = 90,
  Integer $polling_frequency_seconds = 1,
  Boolean $manage_sysstat            = true,
) {
  $scripts_dir = "${output_dir}/scripts"

  # If File[$output_dir] is defined, assume that the puppet_metrics_collector
  # class has defined it and the following resources in init.pp.

  if !defined(File[$output_dir]) {
    file { [$output_dir, $scripts_dir]:
      ensure => directory,
    }

    file { "${scripts_dir}/create-archive":
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/create-archive'
    }

    file { "${scripts_dir}/metrics_tidy":
      ensure => file,
      mode   => '0744',
      source => 'puppet:///modules/puppet_metrics_collector/metrics_tidy'
    }
  }


  file { "${scripts_dir}/system_metrics":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/puppet_metrics_collector/system_metrics'
  }

  if $manage_sysstat {
    package { 'sysstat':
      ensure => installed,
    }
  }

  include puppet_metrics_collector::system::cpu
  include puppet_metrics_collector::system::memory
  include puppet_metrics_collector::system::processes

  # LEGACY CLEANUP

  $metric_legacy_files = [
    "${scripts_dir}/generate_system_metrics",
  ]

  file { $metric_legacy_files :
    ensure => absent,
  }
}
