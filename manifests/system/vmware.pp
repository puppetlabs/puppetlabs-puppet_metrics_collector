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
  String  $metrics_shipping_command  = $puppet_metrics_collector::system::metrics_shipping_command,
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
                      $metrics_shipping_command,
                      '> /dev/null'].join(' ')

  $tidy_command = "${puppet_metrics_collector::system::scripts_dir}/metrics_tidy -d ${metrics_output_dir} -r ${retention_days}"

  if ($metrics_ensure == 'present') and (!$facts.dig('puppet_metrics_collector', 'have_vmware_tools')) {
    notify { 'vmware_tools_warning':
      message  => 'VMware metrics collection requires vmware-toolbox-cmd to be on the PATH',
      loglevel => warning,
    }
  }

  puppet_metrics_collector::collect {'vmware':
    metrics_command => $metrics_command,
    tidy_command    => $tidy_command,
    metric_ensure   => $metrics_ensure,
    minute          => String("0/${collection_frequency}"),
    notify          => Exec['puppet_metrics_collector_system_daemon_reload'],
  }

  # Legacy cleanup
  cron { ['vmware_metrics_tidy', 'vmware_metrics_collection']:
    ensure => absent
  }
}
