# @summary Generate the metrics shipping command for the cron job including remote metrics
# @param scripts_dir the path to the scripts directory
# @param metrics_server_type the metric server type
# @param metrics_server_hostname the metric server's address
# @param metrics_server_db_name the influxdb database name
# @param metrics_server_port the port to connect to
# @return [String] of the metrics command or undef
function puppet_metrics_collector::generate_metrics_server_command (
  Optional[String]                                   $scripts_dir,
  Optional[Enum['influxdb','graphite','splunk_hec']] $metrics_server_type = undef,
  Optional[String]                                   $metrics_server_hostname = undef,
  Optional[String]                                   $metrics_server_db_name = undef,
  Optional[Integer]                                  $metrics_server_port = undef,
  )  >> String  {
  if !empty($metrics_server_type) {
    if empty($metrics_server_db_name) and $metrics_server_type == 'influxdb'  {
      fail('When specifying an InfluxDB metrics server, you must specify a metrics server db_name')
    }

    $port_command = empty($metrics_server_port) ? {
      false => "--port ${metrics_server_port}",
      true  => undef,
    }

    # We use only the base metrics command for the 'splunk_hec' metrics server type.

    $metrics_shipping_command = $metrics_server_type ? {
      'influxdb'   => ['--print |',
                      "${scripts_dir}/json2timeseriesdb",
                      "--netcat ${metrics_server_hostname}",
                      "--convert-to ${metrics_server_type}",
                      "--influx-db ${metrics_server_db_name}",
                      $port_command,
                      '-',
                      ].filter |$v| { $v != undef }.join(' '), # Filter out undef without stdlib
      'graphite'   => join(['--print |',
                      "${scripts_dir}/json2timeseriesdb",
                      "--netcat ${metrics_server_hostname}",
                      "--convert-to ${metrics_server_type}",
                      '-',
                      ], ' '),
      'splunk_hec' => join(['--print |',
                      '/opt/puppetlabs/bin/puppet',
                      'splunk_hec',
                      '--sourcetype puppet:metrics',
                      '--pe_metrics',
                      ], ' '),
      default      => '',
    }
  } else {
    $metrics_shipping_command = ''
  }
}
