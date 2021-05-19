# Collect System Metrics
class puppet_metrics_collector::system (
  String  $system_metrics_ensure     = 'present',
  String  $output_dir                = '/opt/puppetlabs/puppet-metrics-collector',
  Integer $collection_frequency      = 5, # minutes
  Integer $retention_days            = 90,
  Integer $polling_frequency_seconds = 1,
  Boolean $manage_sysstat            = true,
  Boolean $manage_vmware_tools       = false,
  String  $vmware_tools_pkg          = 'open-vm-tools',
) {
  $scripts_dir = "${output_dir}/scripts"

  # If File[$output_dir] is defined, assume that the puppet_metrics_collector
  # class has defined it and the following resources in init.pp.

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

  exec { 'puppet_metrics_collector_system_daemon_reload':
    command     => 'systemctl daemon-reload',
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
  }

  include puppet_metrics_collector::system::cpu
  include puppet_metrics_collector::system::memory
  include puppet_metrics_collector::system::processes

  if $facts['virtual'] == 'vmware' {
    if $manage_vmware_tools and ($system_metrics_ensure == 'present') {
      package {$vmware_tools_pkg:
        ensure => present,
      }
    }

    file { "${scripts_dir}/vmware_metrics":
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/vmware_metrics'
    }

    contain puppet_metrics_collector::system::vmware
  }

  if $facts.dig('puppet_metrics_collector', 'have_pe_psql') {
    file { "${scripts_dir}/psql_metrics":
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/psql_metrics'
    }

    contain puppet_metrics_collector::system::postgres
  }

  # LEGACY CLEANUP

  $metric_legacy_files = [
    "${scripts_dir}/generate_system_metrics",
  ]

  file { $metric_legacy_files :
    ensure => absent,
  }
}
