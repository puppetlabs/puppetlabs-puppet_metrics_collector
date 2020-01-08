class puppet_metrics_collector::bolt (
  Integer       $collection_frequency = $puppet_metrics_collector::collection_frequency,
  Integer       $retention_days       = $puppet_metrics_collector::retention_days,
  String        $metrics_ensure       = $puppet_metrics_collector::bolt_metrics_ensure,
  Array[String] $hosts                = $puppet_metrics_collector::bolt_hosts,
  Integer       $port                 = $puppet_metrics_collector::bolt_port,
  Optional[Enum['influxdb','graphite','splunk_hec']] $metrics_server_type = $puppet_metrics_collector::metrics_server_type,
  Optional[String]  $metrics_server_hostname = $puppet_metrics_collector::metrics_server_hostname,
  Optional[Integer] $metrics_server_port     = $puppet_metrics_collector::metrics_server_port,
  Optional[String]  $metrics_server_db_name  = $puppet_metrics_collector::metrics_server_db_name,
  Optional[Array[String]] $excludes          = $puppet_metrics_collector::bolt_excludes,
  ) {
  Puppet_metrics_collector::Puma_metric {
    output_dir     => $puppet_metrics_collector::output_dir,
    scripts_dir    => $puppet_metrics_collector::scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
  }

  puppet_metrics_collector::puma_metric { 'bolt' :
    metric_ensure           => $metrics_ensure,
    hosts                   => $hosts,
    metrics_port            => $port,
    metrics_server_type     => $metrics_server_type,
    metrics_server_hostname => $metrics_server_hostname,
    metrics_server_port     => $metrics_server_port,
    metrics_server_db_name  => $metrics_server_db_name,
    excludes                => $excludes,
  }
}
