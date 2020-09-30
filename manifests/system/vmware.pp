# Collect VMware metrics
#
# This class manages a cron job that collects metrics from:
#
#     vmware-toolbox-cmd stat
#
# This class should not be included directly.
# Include {puppet_metrics_collector::system} instead.
#
# @private
class puppet_metrics_collector::system::vmware (
  String  $metrics_ensure            = $puppet_metrics_collector::system::system_metrics_ensure,
  Integer $collection_frequency      = $puppet_metrics_collector::system::collection_frequency,
  Integer $retention_days            = $puppet_metrics_collector::system::retention_days,
) {
  $metrics_output_dir = "${puppet_metrics_collector::system::output_dir}/vmware"
  $metrics_output_dir_ensure = $metrics_ensure ? {
    'present' => directory,
    'absent'  => absent,
  }

  file { $metrics_output_dir:
    ensure => $metrics_output_dir_ensure,
    # Allow directories to be removed.
    force  => true,
  }

  $metrics_command = ["${puppet_metrics_collector::system::scripts_dir}/vmware_metrics",
                      '--output_dir', $metrics_output_dir,
                      '> /dev/null'].join(' ')

  if ($metrics_ensure == 'present') and (!$facts.dig('puppet_metrics_collector', 'have_vmware_tools')) {
    notify { 'vmware_tools_warning':
      message  => 'VMware metrics collection requires vmware-toolbox-cmd to be on the PATH',
      loglevel => warning,
    }
    # Set cron job to absent to avoid spamming mailboxes with errors.
    $_cron_ensure = 'absent'
  } else {
    $_cron_ensure = $metrics_ensure
  }

  cron { 'vmware_metrics_collection':
    ensure  => $_cron_ensure,
    command => $metrics_command,
    user    => 'root',
    minute  => "*/${collection_frequency}",
  }

  # The hardcoded numbers with the fqdn_rand calls are to trigger the metrics_tidy
  # command to run at a randomly selected time between 12:00 AM and 3:00 AM.
  # NOTE - if adding a new service, the name of the service must be added to the valid_paths array in files/metrics_tidy

  cron { 'vmware_metrics_tidy':
    ensure  => $metrics_ensure,
    command => "${puppet_metrics_collector::system::scripts_dir}/metrics_tidy -d ${metrics_output_dir} -r ${retention_days}",
    user    => 'root',
    hour    => fqdn_rand(3, 'vmware'),
    minute  => (5 * fqdn_rand(11, 'vmware')),
  }
}
