class puppet_metrics_collector::orchestrator (
  Integer       $collection_frequency = $puppet_metrics_collector::collection_frequency,
  Integer       $retention_days       = $puppet_metrics_collector::retention_days,
  String        $metrics_ensure       = $puppet_metrics_collector::orchestrator_metrics_ensure,
  Array[String] $hosts                = $puppet_metrics_collector::orchestrator_hosts,
  Integer       $port                 = $puppet_metrics_collector::orchestrator_port,
  Optional[Puppet_metrics_collector::Metrics_server] $metrics_server_info = $puppet_metrics_collector::metrics_server_info,
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
    metrics_server_info => $metrics_server_info,
  }
}
