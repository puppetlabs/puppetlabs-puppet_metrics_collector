define puppet_metrics_collector::pe_metric (
  String                    $output_dir,
  String                    $scripts_dir,
  Integer                   $metrics_port,
  String                    $pipe_string,
  Enum['absent', 'present'] $metric_ensure  = 'present',
  String                    $metrics_type   = $title,
  Array[String]             $hosts          = [ '127.0.0.1' ],
  String                    $cron_minute    = '*/5',
  Integer                   $retention_days = 90,
  String                    $metric_script_file = 'tk_metrics',
  Array[Hash]               $additional_metrics = [],
  Boolean                   $ssl                = true,
) {
  $has_pipe = ( $pipe_string ) and ($pipe_string != '')
  $metrics_output_dir = "${output_dir}/${metrics_type}"

  file { $metrics_output_dir :
    ensure => $metric_ensure ? {
      'present' => directory,
      'absent'  => absent,
    },
  }

  $config_hash = {
    'hosts'              => $hosts.sort(),
    'metrics_type'       => $metrics_type,
    'metrics_port'       => $metrics_port,
    'additional_metrics' => $additional_metrics,
    'clientcert'         => $::clientcert,
    'pe_version'         => $facts['pe_server_version'],
    'ssl'                => $ssl,
  }

  file { "${scripts_dir}/${metrics_type}_config.yaml" :
    ensure  => $metric_ensure,
    mode    => '0644',
    content => $config_hash.puppet_metrics_collector::to_yaml(),
  }

  $script_file_name = "${scripts_dir}/${metric_script_file}"

  # let us pipe this to a different thing entirely
  if $has_pipe {
    $command_string = "${script_file_name} --metrics_type ${metrics_type} --print | ${pipe_string}"
  }
  else {
    $command_string = "${script_file_name} --metrics_type ${metrics_type} --output-dir ${metrics_output_dir} --no-print"
  }

  cron { "${metrics_type}_metrics_collection" :
    ensure  => $metric_ensure,
    command => $command_string,
    user    => 'root',
    minute  => $cron_minute,
  }

  # now we only install these jobs we're not piping it
  $metrics_tidy_script_path = "${scripts_dir}/${metrics_type}_metrics_tidy"

  if ! $has_pipe {
    file { $metrics_tidy_script_path :
      ensure  => $metric_ensure,
      mode    => '0744',
      content => epp('puppet_metrics_collector/tidy_cron.epp', {
        'metrics_output_dir' => $metrics_output_dir,
        'metrics_type'       => $metrics_type,
        'retention_days'     => $retention_days,
      }),
    }

    cron { "${metrics_type}_metrics_tidy" :
      ensure  => $metric_ensure,
      user    => 'root',
      hour    => fqdn_rand(3,  $metrics_type ),
      minute  => (5 * fqdn_rand(11, $metrics_type )),
      command => $metrics_tidy_script_path
    }
  }
  elsif $has_pipe {
    file { $metrics_tidy_script_path:
      ensure => absent,
    }

    cron { "${metrics_type}_metrics_tidy" :
      ensure => absent,
    }
  }

  #Cleanup old scripts
  $old_script_file_names = [
    "${scripts_dir}/${metrics_type}_metrics.sh",
    "${scripts_dir}/${metrics_type}_metrics"
  ]

  file { $old_script_file_names :
    ensure  => absent,
  }
}
