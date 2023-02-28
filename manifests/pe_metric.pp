# @summary A defined type to manage the configuration of tbe different metrics collection targets
define puppet_metrics_collector::pe_metric (
  String                    $metrics_type             = $title,
  Enum['absent', 'present'] $metric_ensure            = 'present',
  String                    $cron_minute              = '0/5',
  Integer                   $retention_days           = 90,
  Array[String]             $hosts                    = ['127.0.0.1'],
  Integer                   $metrics_port             = undef,
  String                    $metric_script_file       = 'tk_metrics',
  Boolean                   $ssl                      = true,
  Array[String]             $excludes                 = puppet_metrics_collector::version_based_excludes($title),
  Array[Hash]               $additional_metrics       = [],
  Optional[String]          $override_metrics_command = undef,
  Optional[Enum['splunk_hec']]   $metrics_server_type = undef,
  Optional[Hash]            $env_vars                 = undef,
) {
  $metrics_output_dir = "${puppet_metrics_collector::output_dir}/${metrics_type}"

  $metrics_output_dir_ensure = $metric_ensure ? {
    'present' => directory,
    'absent'  => absent,
  }

  file { $metrics_output_dir :
    ensure => $metrics_output_dir_ensure,
    # Allow directories to be removed.
    force  => true,
  }

  $config_hash = {
    'metrics_type'           => $metrics_type,
    'pe_version'             => $facts['pe_server_version'],
    'hosts'                  => $hosts,
    'metrics_port'           => $metrics_port,
    'ssl'                    => $ssl,
    'excludes'               => $excludes,
    'additional_metrics'     => $additional_metrics,
  }

  file { "${puppet_metrics_collector::config_dir}/${metrics_type}.yaml" :
    ensure  => $metric_ensure,
    mode    => '0644',
    content => $config_hash.puppet_metrics_collector::to_yaml(),
  }

  $metric_script_file_path = "${puppet_metrics_collector::scripts_dir}/${metric_script_file}"

  if empty($override_metrics_command) {
    $base_metrics_command = "${metric_script_file_path} --metrics_type ${metrics_type} --output_dir ${metrics_output_dir}"
    $metrics_shipping_command = join(['--print |',
        '/opt/puppetlabs/bin/puppet',
        'splunk_hec',
        '--sourcetype puppet:metrics',
        '--pe_metrics',
    ], ' ')

    if !empty($metrics_server_type) {
      $metrics_command = "${base_metrics_command} ${metrics_shipping_command} > /dev/null"
    } else {
      $metrics_command = "${base_metrics_command} --no-print"
    }
  } else {
    $metrics_command = $override_metrics_command
  }

  $tidy_command = "${puppet_metrics_collector::scripts_dir}/metrics_tidy -d ${metrics_output_dir} -r ${retention_days}"

  puppet_metrics_collector::collect { $metrics_type:
    ensure          => $metric_ensure,
    metrics_command => $metrics_command,
    tidy_command    => $tidy_command,
    metric_ensure   => $metric_ensure,
    minute          => $cron_minute,
    env_vars        => $env_vars,
    notify          => Exec['puppet_metrics_collector_daemon_reload'],
  }

  # LEGACY CLEANUP
  cron { "${metrics_type}_metrics_collection" :
    ensure  => absent,
  }

  cron { "${metrics_type}_metrics_tidy" :
    ensure  => absent,
  }

  $metric_legacy_files = [
    "${puppet_metrics_collector::scripts_dir}/${metrics_type}_config.yaml",
    "${puppet_metrics_collector::scripts_dir}/${metrics_type}_metrics_tidy",
    "${puppet_metrics_collector::scripts_dir}/${metrics_type}_metrics.sh",
    "${puppet_metrics_collector::scripts_dir}/${metrics_type}_metrics",
  ]

  file { $metric_legacy_files :
    ensure => absent,
  }
}
