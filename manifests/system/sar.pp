# @summary Collects System CPU Metrics
#
# @api private
#
class puppet_metrics_collector::system::sar (
  String  $metrics_ensure            = $puppet_metrics_collector::system::system_metrics_ensure,
  Integer $collection_frequency      = $puppet_metrics_collector::system::collection_frequency,
  Integer $retention_days            = $puppet_metrics_collector::system::retention_days,
  Integer $polling_frequency_seconds = $puppet_metrics_collector::system::polling_frequency_seconds,
  Optional[String] $metrics_shipping_command  = undef,
) {
  # This is to ensure that files are written to a directory that the sup script will pick up
  puppet_metrics_collector::sar_metric { 'system_cpu' :
    metric_ensure             => $metrics_ensure,
    cron_minute               => "0/${collection_frequency}",
    retention_days            => $retention_days,
    collection_frequency      => $collection_frequency,
    polling_frequency_seconds => $polling_frequency_seconds,
    metrics_shipping_command  => $metrics_shipping_command,
    # This ensures that sar reports the time field as one 24 hour field, instead of a 12 hour format with spaces
    env_vars                  => { 'LC_TIME' => 'POSIX' },
  }
}
