type Puppet_metrics_collector::Metrics_server = Struct[{
  metrics_server_type => Enum['influxdb','graphite', 'splunk_hec'],
  hostname            => String,
  port                => Optional[Integer],
  db_name             => Optional[String],
}]
