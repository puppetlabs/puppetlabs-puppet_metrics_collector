# Collect System CPU Metrics
class puppet_metrics_collector::system::cpu (
  String  $metrics_ensure            = $puppet_metrics_collector::system::system_metrics_ensure,
  Integer $collection_frequency      = $puppet_metrics_collector::system::collection_frequency,
  Integer $retention_days            = $puppet_metrics_collector::system::retention_days,
  Integer $polling_frequency_seconds = $puppet_metrics_collector::system::polling_frequency_seconds,
  ) {
  puppet_metrics_collector::sar_metric { 'system_cpu' :
    metric_ensure             => $metrics_ensure,
    cron_minute               => "0/${collection_frequency}",
    retention_days            => $retention_days,
    collection_frequency      => $collection_frequency,
    polling_frequency_seconds => $polling_frequency_seconds,
  }
}
