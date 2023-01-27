# @summary
#   This class manages collect postgres and system metrics
# 
# @param system_metrics_ensure 
#   Whether to enable or disable the collection of System metrics. Valid values are 'present', and 'absent'. Default : 'present'
# 
# @param output_dir
#   The directory to write the metrics to. Default: '/opt/puppetlabs/puppet-metrics-collector'
# 
# @param collection_frequency
#   The frequency to collect metrics in minutes. Default: '5'
# 
# @param retention_days
#   The number of days to retain metrics. Default: '90'
# 
# @param polling_frequency_seconds
# 
# @param manage_sysstat
# 
# @param manage_vmware_tools 
# 
# @param vmware_tools_pkg 
# 
# @param metrics_server_type
# 
# @param metrics_server_hostname
# 
# @param metrics_server_port 
# 
# @param metrics_server_db_name 
# 
class puppet_metrics_collector::system (
  String  $system_metrics_ensure     = 'present',
  String  $output_dir                = '/opt/puppetlabs/puppet-metrics-collector',
  Integer $collection_frequency      = 5, # minutes
  Integer $retention_days            = 90,
  Integer $polling_frequency_seconds = 1,
  Boolean $manage_sysstat            = false,
  Boolean $manage_vmware_tools       = false,
  String  $vmware_tools_pkg          = 'open-vm-tools',
  Optional[Enum['influxdb', 'graphite', 'splunk_hec']] $metrics_server_type = getvar('puppet_metrics_collector::metrics_server_type'),
  Optional[String] $metrics_server_hostname   = getvar('puppet_metrics_collector::metrics_server_hostname'),
  Optional[Integer] $metrics_server_port      = getvar('puppet_metrics_collector::metrics_server_port'),
  Optional[String] $metrics_server_db_name    = getvar('puppet_metrics_collector::metrics_server_db_name'),
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
      source => 'puppet:///modules/puppet_metrics_collector/create-metrics-archive',
    }

    file { "${scripts_dir}/metrics_tidy":
      ensure => file,
      mode   => '0744',
      source => 'puppet:///modules/puppet_metrics_collector/metrics_tidy',
    }
  }

  exec { 'puppet_metrics_collector_system_daemon_reload':
    command     => 'systemctl daemon-reload',
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
  }

  $metrics_shipping_command = puppet_metrics_collector::generate_metrics_server_command(
    $scripts_dir,
    $metrics_server_type,
    $metrics_server_hostname,
    $metrics_server_db_name,
    $metrics_server_port
  )

  if $manage_sysstat {
    package { 'sysstat':
      ensure => $system_metrics_ensure,
    }
  }

  if $manage_sysstat or $facts.dig('puppet_metrics_collector', 'have_sysstat') {
    file { "${scripts_dir}/system_metrics":
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/system_metrics',
    }

    contain puppet_metrics_collector::system::sar
    contain puppet_metrics_collector::system::processes
  }

  if $facts['virtual'] == 'vmware' {
    if $manage_vmware_tools and ($system_metrics_ensure == 'present') {
      package { $vmware_tools_pkg:
        ensure => present,
      }
    }

    file { "${scripts_dir}/vmware_metrics":
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/vmware_metrics',
    }

    contain puppet_metrics_collector::system::vmware
  }

  if $facts.dig('puppet_metrics_collector', 'have_pe_psql') {
    file { "${scripts_dir}/psql_metrics":
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/puppet_metrics_collector/psql_metrics',
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

  $legacy_sar = ['system_memory']
  puppet_metrics_collector::collect { $legacy_sar:
    ensure => absent,
    metrics_command => 'foo',
    tidy_command => 'bar',
  }
}
