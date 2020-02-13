class puppet_metrics_collector::system_cpu (
  Integer $collection_frequency      = $puppet_metrics_collector::system::collection_frequency,
  Integer $polling_frequency_seconds = $puppet_metrics_collector::system::polling_frequency_seconds,
  Integer $retention_days            = $puppet_metrics_collector::system::retention_days,
  String  $metrics_ensure            = $puppet_metrics_collector::system::system_metrics_ensure,
  ) {
  Puppet_metrics_collector::Sar_metric {
    output_dir                => $puppet_metrics_collector::system::output_dir,
    scripts_dir               => $puppet_metrics_collector::system::scripts_dir,
    cron_minute               => "*/${collection_frequency}",
    collection_frequency      => $collection_frequency,
    polling_frequency_seconds => $polling_frequency_seconds,
    retention_days            => $retention_days,
  }

  puppet_metrics_collector::sar_metric { 'system_cpu' :
    metric_ensure             => $metrics_ensure,
  }
}
