# @summary
#   This class manages the collections of SAR metrics
#   
# @param collection_frequency
#   The frequency to collect metrics in minutes. Default: '5'
# 
# @param retention_days
#   The number of days to retain metrics. Default: '90'
# 
# @param polling_frequency_seconds
# How often the target is requested to provide data, in seconds. Default: 1
# 
# @param cron_minute
#   The minute to run the cron job. Default: '0/5'
# @param metrics_type 
#   The string aide to identify the metrics type,
#   this is used to create the metrics file name.
#
# @param metric_ensure
#   The ensure value for the metrics file. Default: 'present'
#
# @param metric_script_file 
#   The script file to run to collect the metrics. Default: 'system_metrics'
#
# @param metrics_shipping_command
#   The parameter that defines the command for the remote shipping of metrics. Default: '$puppet_metrics_collector::system::metrics_shipping_command'
define puppet_metrics_collector::sar_metric (
  String                    $metrics_type              = $title,
  Enum['absent', 'present'] $metric_ensure             = 'present',
  String                    $cron_minute               = '0/5',
  Integer                   $retention_days            = 90,
  Integer                   $collection_frequency      = 5, # minutes
  Integer                   $polling_frequency_seconds = 1,
  String                    $metric_script_file        = 'system_metrics',
  String                    $metrics_shipping_command  = $puppet_metrics_collector::system::metrics_shipping_command,
  Optional[Hash]     $env_vars                  = undef,
) {
  $metrics_output_dir = "${puppet_metrics_collector::system::output_dir}/${metrics_type}"

  $metrics_output_dir_ensure = $metric_ensure ? {
    'present' => directory,
    'absent'  => absent,
  }

  file { $metrics_output_dir :
    ensure => $metrics_output_dir_ensure,
    # Allow directories to be removed.
    force  => true,
  }

  $metric_script_file_path = "${puppet_metrics_collector::system::scripts_dir}/${metric_script_file}"
  $file_interval_seconds = $collection_frequency * 60

  $base_metrics_command = join([$metric_script_file_path,
      "--metric_type ${metrics_type}",
      "--file_interval ${file_interval_seconds}",
      "--polling_interval ${polling_frequency_seconds}",
      "--metrics_dir ${puppet_metrics_collector::system::output_dir}",
  ], ' ')

  $metrics_command = "${base_metrics_command} ${metrics_shipping_command} > /dev/null"

  # The hardcoded numbers with the fqdn_rand calls are to trigger the metrics_tidy 
  # command to run at a randomly selected time between 12:00 AM and 3:00 AM.
  # NOTE - if adding a new service, the name of the service must be added to the valid_paths array in files/metrics_tidy

  $tidy_command = "${puppet_metrics_collector::system::scripts_dir}/metrics_tidy -d ${metrics_output_dir} -r ${retention_days}"

  puppet_metrics_collector::collect { $metrics_type:
    ensure          => $metric_ensure,
    metrics_command => $metrics_command,
    tidy_command    => $tidy_command,
    metric_ensure   => $metric_ensure,
    minute          => $cron_minute,
    env_vars        => $env_vars,
    notify          => Exec['puppet_metrics_collector_system_daemon_reload'],
  }

  # LEGACY CLEANUP

  cron { "${metrics_type}_metrics_tidy" :
    ensure  => absent,
  }

  cron { "${metrics_type}_metrics_collection" :
    ensure  => absent,
  }

  $metric_legacy_files = [
    "${puppet_metrics_collector::system::scripts_dir}/${metrics_type}_metrics_tidy",
  ]

  file { $metric_legacy_files :
    ensure => absent,
  }
}
