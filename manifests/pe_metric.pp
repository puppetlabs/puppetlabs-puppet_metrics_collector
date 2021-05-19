# Collect Puma or TrapperKeeper Metrics
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
  Optional[Boolean]         $remote_metrics_enabled   = lookup('puppet_metrics_collector::pe_metric::remote_metrics_enabled', {'default_value' => undef}), # lint:ignore:140chars
  Optional[String]          $override_metrics_command = undef,
  Optional[Enum['influxdb','graphite','splunk_hec']] $metrics_server_type = undef,
  Optional[String]          $metrics_server_hostname  = undef,
  Optional[Integer]         $metrics_server_port      = undef,
  Optional[String]          $metrics_server_db_name   = undef,
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

  $_remote_metrics_enabled = if $remote_metrics_enabled =~ Boolean {
    $remote_metrics_enabled
  } elsif $facts.dig('pe_server_version') =~ NotUndef {
    if versioncmp($facts.dig('pe_server_version'), '2019.8.5') >= 0 {
      true
    } else {
      false
    }
  } else {
    false
  }

  $config_hash = {
    'metrics_type'           => $metrics_type,
    'pe_version'             => $facts['pe_server_version'],
    'clientcert'             => $::clientcert,
    'hosts'                  => $hosts,
    'metrics_port'           => $metrics_port,
    'ssl'                    => $ssl,
    'excludes'               => $excludes,
    'additional_metrics'     => $additional_metrics,
    'remote_metrics_enabled' => $_remote_metrics_enabled,
  }

  file { "${puppet_metrics_collector::config_dir}/${metrics_type}.yaml" :
    ensure  => $metric_ensure,
    mode    => '0644',
    content => $config_hash.puppet_metrics_collector::to_yaml(),
  }

  $metric_script_file_path = "${puppet_metrics_collector::scripts_dir}/${metric_script_file}"
  $conversion_script_file_path = "${puppet_metrics_collector::scripts_dir}/json2timeseriesdb"

  # lint:ignore:140chars
  if empty($override_metrics_command) {
    $base_metrics_command = "${metric_script_file_path} --metrics_type ${metrics_type} --output_dir ${metrics_output_dir}"

    if !empty($metrics_server_type) {
      $server_hostname = $metrics_server_hostname
      $server_port     = $metrics_server_port
      $server_type     = $metrics_server_type
      $server_db       = $metrics_server_db_name

      if empty($server_db) and $server_type == 'influxdb'  {
        fail('When specifying an InfluxDB metrics server, you must specify a metrics server db_name')
      }

      $conv_metrics_command = "${base_metrics_command} | ${conversion_script_file_path} --netcat ${server_hostname} --convert-to ${server_type} -"

      $full_metrics_command = empty($server_port) ? {
        false => "${conv_metrics_command} --port ${server_port}",
        true  => $conv_metrics_command,
      }

      # We use only the base metrics command for the 'splunk_hec' metrics server type.

      $metrics_command = $server_type ? {
        'influxdb'   => "${full_metrics_command} --influx-db ${server_db} > /dev/null",
        'graphite'   => "${full_metrics_command} > /dev/null",
        'splunk_hec' => "${base_metrics_command} | /opt/puppetlabs/bin/puppet splunk_hec --sourcetype puppet:metrics --pe_metrics > /dev/null",
        default      => "${full_metrics_command} > /dev/null",
      }
    } else {
      $metrics_command = "${base_metrics_command} --no-print"
    }
  } else {
    $metrics_command = $override_metrics_command
  }
  # lint:endignore

  $tidy_command = "${puppet_metrics_collector::scripts_dir}/metrics_tidy -d ${metrics_output_dir} -r ${retention_days}"

  puppet_metrics_collector::collect {$metrics_type:
    metrics_command => $metrics_command,
    tidy_command    => $tidy_command,
    metric_ensure   => $metric_ensure,
    minute          => $cron_minute,
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
