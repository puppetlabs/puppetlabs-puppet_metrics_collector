define puppet_metrics_collector::sar_metric (
  String                    $output_dir,
  String                    $scripts_dir,
  Enum['absent', 'present'] $metric_ensure = 'present',
  String                    $metrics_type = $title,
  String                    $cron_minute = '*/5',
  Integer                   $retention_days = 90,
  Integer                   $polling_frequency_seconds = 1,
  Integer                   $collection_frequency = 5, #minutes
  String                    $metric_script_file = 'generate_system_metrics',
) {

  $metrics_output_dir = "${output_dir}/${metrics_type}"

  $_metric_ensure = $metric_ensure ? {
    'present' => directory,
    'absent'  => absent,
  }

  file { $metrics_output_dir :
    ensure => $_metric_ensure,
  }

  $script_file_name = "${scripts_dir}/${metric_script_file}"
  $file_interval_seconds = $collection_frequency * 60

  $metrics_command = join(["${script_file_name} --metric_type ${metrics_type}",
                            " --file_interval ${file_interval_seconds}",
                            " --polling_interval ${polling_frequency_seconds}",
                            " --metrics_dir ${output_dir}"], '')

  cron { "${metrics_type}_metrics_collection" :
    ensure  => $metric_ensure,
    command => $metrics_command,
    user    => 'root',
    minute  => $cron_minute,
  }

  $metrics_tidy_script_path = "${scripts_dir}/${metrics_type}_metrics_tidy"

  file { $metrics_tidy_script_path :
    ensure  => $metric_ensure,
    mode    => '0744',
    content => epp('puppet_metrics_collector/tidy_cron.epp', {
      'metrics_output_dir' => $metrics_output_dir,
      'metrics_type'       => $metrics_type,
      'retention_days'     => $retention_days,
    }),
  }

  # The hardcoded numbers with the fqdn call are to trigger the tidy to run at a randomly selected
  # time between 12:00 AM and 3:00 AM
  cron { "${metrics_type}_metrics_tidy" :
    ensure  => $metric_ensure,
    user    => 'root',
    hour    => fqdn_rand(3, $metrics_type),
    minute  => (5 * fqdn_rand(11, $metrics_type)),
    command => $metrics_tidy_script_path
  }
}
