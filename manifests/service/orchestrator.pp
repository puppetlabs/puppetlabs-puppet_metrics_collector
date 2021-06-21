# Collect Service Metrics
class puppet_metrics_collector::service::orchestrator (
  String                  $metrics_ensure           = $puppet_metrics_collector::orchestrator_metrics_ensure,
  Integer                 $collection_frequency     = $puppet_metrics_collector::collection_frequency,
  Integer                 $retention_days           = $puppet_metrics_collector::retention_days,
  Array[String]           $hosts                    = $puppet_metrics_collector::orchestrator_hosts,
  Integer                 $port                     = $puppet_metrics_collector::orchestrator_port,
  Array[Hash]             $extra_metrics            = [],
  Optional[String]        $override_metrics_command = $puppet_metrics_collector::override_metrics_command,
  Optional[Array[String]] $excludes                 = $puppet_metrics_collector::orchestrator_excludes,
  Optional[Enum['influxdb', 'graphite', 'splunk_hec']] $metrics_server_type = $puppet_metrics_collector::metrics_server_type,
  Optional[String]        $metrics_server_hostname  = $puppet_metrics_collector::metrics_server_hostname,
  Optional[Integer]       $metrics_server_port      = $puppet_metrics_collector::metrics_server_port,
  Optional[String]        $metrics_server_db_name   = $puppet_metrics_collector::metrics_server_db_name,
  ) {
  puppet_metrics_collector::pe_metric { 'orchestrator' :
    metric_ensure            => $metrics_ensure,
    cron_minute              => "0/${collection_frequency}",
    retention_days           => $retention_days,
    hosts                    => $hosts,
    metrics_port             => $port,
    additional_metrics       => $extra_metrics,
    override_metrics_command => $override_metrics_command,
    excludes                 => $excludes,
    metrics_server_type      => $metrics_server_type,
    metrics_server_hostname  => $metrics_server_hostname,
    metrics_server_port      => $metrics_server_port,
    metrics_server_db_name   => $metrics_server_db_name,
  }
}
