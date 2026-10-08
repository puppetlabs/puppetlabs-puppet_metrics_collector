# @summary Collect puppetserver metrics
#
# @api private
#
class puppet_metrics_collector::service::puppetserver (
  String                  $metrics_ensure           = $puppet_metrics_collector::puppetserver_metrics_ensure,
  Integer                 $collection_frequency     = $puppet_metrics_collector::collection_frequency,
  Integer                 $retention_days           = $puppet_metrics_collector::retention_days,
  Array[String]           $hosts                    = $puppet_metrics_collector::puppetserver_hosts,
  Integer                 $port                     = $puppet_metrics_collector::puppetserver_port,
  Array[Hash]             $extra_metrics            = [],
  Optional[String]        $override_metrics_command = $puppet_metrics_collector::override_metrics_command,
  Optional[Array[String]] $excludes                 = $puppet_metrics_collector::puppetserver_excludes,
  Optional[Enum['influxdb', 'graphite', 'splunk_hec']] $metrics_server_type = $puppet_metrics_collector::metrics_server_type,
  Optional[String]        $metrics_server_hostname  = $puppet_metrics_collector::metrics_server_hostname,
  Optional[Integer]       $metrics_server_port      = $puppet_metrics_collector::metrics_server_port,
  Optional[String]        $metrics_server_db_name   = $puppet_metrics_collector::metrics_server_db_name,
) {
  puppet_metrics_collector::deprecated_parameter { 'puppet_metrics_collector::service::puppetserver::metrics_server_type': }
  puppet_metrics_collector::deprecated_parameter { 'puppet_metrics_collector::service::puppetserver::metrics_server_hostname': }
  puppet_metrics_collector::deprecated_parameter { 'puppet_metrics_collector::service::puppetserver::metrics_server_port': }
  puppet_metrics_collector::deprecated_parameter { 'puppet_metrics_collector::service::puppetserver::metrics_server_db_name': }

  $filesync_storage_metrics = [
    {
      'type'  => 'read',
      'name'  => 'file-sync-storage-commit-timer',
      'mbean' => 'puppetserver:name=puppetlabs.*.file-sync-storage.commit-timer'
    },
    {
      'type'  => 'read',
      'name'  => 'file-sync-storage-pre-commit-hook-timer',
      'mbean' => 'puppetserver:name=puppetlabs.*.file-sync-storage.pre-commit-hook-timer'
    },
    {
      'type' => 'read',
      'name' => 'file-sync-storage-commit-add-rm-timer',
      'mbean' => 'puppetserver:name=puppetlabs.*.file-sync-storage.commit-add-rm-timer'
    },
  ]

  # Registered by Puppet Server versions that support the drain window, so collected whether or
  # not file sync is enabled. Counts how often the drain-window version-count cap, rather than its
  # duration, cut short the protection of an in-flight code version. A rising rate means code is
  # being deployed faster than in-flight runs can be protected, so some runs may get a 410 and
  # reconverge on a later run.
  # A server that does not register it reports a 404 for that mbean in the bulk response (Jolokia:
  # no MBean matched the pattern), which the collector records as null without counting an error.
  $code_version_metrics = [
    {
      'type'  => 'read',
      'name'  => 'code-version-count-cap-binding',
      'mbean' => 'puppetserver:name=puppetlabs.*.puppetserver.code-version.count-cap-binding'
    },
  ]

  $additional_metrics = $facts.dig('puppet_metrics_collector', 'file_sync_storage_enabled') ? {
    true    => $filesync_storage_metrics + $code_version_metrics + $extra_metrics,
    default => $code_version_metrics + $extra_metrics,
  }

  puppet_metrics_collector::pe_metric { 'puppetserver' :
    metric_ensure            => $metrics_ensure,
    cron_minute              => "0/${collection_frequency}",
    retention_days           => $retention_days,
    hosts                    => $hosts,
    metrics_port             => $port,
    override_metrics_command => $override_metrics_command,
    excludes                 => $excludes,
    additional_metrics       => $additional_metrics,
    metrics_server_type      => $metrics_server_type ? {
      'splunk_hec' => 'splunk_hec',
      default      => undef,
    },
  }
}
