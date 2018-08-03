class puppet_metrics_collector::console (
  Integer       $collection_frequency = $puppet_metrics_collector::collection_frequency,
  Integer       $retention_days       = $puppet_metrics_collector::retention_days,
  String        $metrics_ensure       = $puppet_metrics_collector::console_metrics_ensure,
  Array[String] $hosts                = $puppet_metrics_collector::console_hosts,
  Integer       $port                 = $puppet_metrics_collector::console_port,
) {
  Puppet_metrics_collector::Pe_metric {
    output_dir     => $puppet_metrics_collector::output_dir,
    scripts_dir    => $puppet_metrics_collector::scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
  }

  puppet_metrics_collector::pe_metric { 'console' :
    metric_ensure => $metrics_ensure,
    hosts         => $hosts,
    metrics_port  => $port,
  }
}
