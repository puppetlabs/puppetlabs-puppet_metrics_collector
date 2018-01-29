class puppet_metrics_collector::orchestrator (
  Integer       $collection_frequency = $puppet_metrics_collector::collection_frequency,
  Integer       $retention_days       = $puppet_metrics_collector::retention_days,
  String        $metrics_ensure       = $puppet_metrics_collector::orchestrator_metrics_ensure,
  Array[String] $hosts                = $puppet_metrics_collector::orchestrator_hosts,
  Integer       $port                 = $puppet_metrics_collector::orchestrator_port,
  Optional[String] $influxdb_host     = $puppet_metrics_collector::influxdb_host,
) {
  Puppet_metrics_collector::Pe_metric {
    output_dir     => $puppet_metrics_collector::output_dir,
    scripts_dir    => $puppet_metrics_collector::scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
  }

  puppet_metrics_collector::pe_metric { 'orchestrator' :
    metric_ensure => $metrics_ensure,
    hosts         => $hosts,
    metrics_port  => $port,
    influxdb_host => $influxdb_host,
  }
}
