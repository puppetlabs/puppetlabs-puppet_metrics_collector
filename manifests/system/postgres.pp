# Collect PostgreSQL metrics
#
# This class manages a cron job that uses `/opt/puppetlabs/server/bin/psql`
# to collect metrics from a locally-running `pe-postgresql` service.
#
# This class should not be included directly.
# Include {puppet_metrics_collector::system} instead.
#
# @private
class puppet_metrics_collector::system::postgres (
  String  $metrics_ensure            = $puppet_metrics_collector::system::system_metrics_ensure,
  Integer $collection_frequency      = $puppet_metrics_collector::system::collection_frequency,
  Integer $retention_days            = $puppet_metrics_collector::system::retention_days,
) {
  $metrics_output_dir = "${puppet_metrics_collector::system::output_dir}/postgres"
  $metrics_output_dir_ensure = $metrics_ensure ? {
    'present' => directory,
    'absent'  => absent,
  }

  file { $metrics_output_dir:
    ensure => $metrics_output_dir_ensure,
    # Allow directories to be removed.
    force  => true,
  }

  $metrics_command = ["${puppet_metrics_collector::system::scripts_dir}/psql_metrics",
                      '--output_dir', $metrics_output_dir,
                      '> /dev/null'].join(' ')

  cron { 'postgres_metrics_collection':
    ensure  => $metrics_ensure,
    command => $metrics_command,
    user    => 'root',
    minute  => "*/${collection_frequency}",
  }

  # The hardcoded numbers with the fqdn_rand calls are to trigger the metrics_tidy
  # command to run at a randomly selected time between 12:00 AM and 3:00 AM.
  # NOTE - if adding a new service, the name of the service must be added to the valid_paths array in files/metrics_tidy

  cron { 'postgres_metrics_tidy':
    ensure  => $metrics_ensure,
    command => "${puppet_metrics_collector::system::scripts_dir}/metrics_tidy -d ${metrics_output_dir} -r ${retention_days}",
    user    => 'root',
    hour    => fqdn_rand(3, 'postgres'),
    minute  => (5 * fqdn_rand(11, 'postgres')),
  }
}
