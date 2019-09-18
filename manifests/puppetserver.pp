class puppet_metrics_collector::puppetserver (
  Integer       $collection_frequency = $puppet_metrics_collector::collection_frequency,
  Integer       $retention_days       = $puppet_metrics_collector::retention_days,
  String        $metrics_ensure       = $puppet_metrics_collector::puppetserver_metrics_ensure,
  Array[String] $hosts                = $puppet_metrics_collector::puppetserver_hosts,
  Integer       $port                 = $puppet_metrics_collector::puppetserver_port,
  Optional[Enum['influxdb','graphite','splunk_hec']] $metrics_server_type = $puppet_metrics_collector::metrics_server_type,
  Optional[String]  $metrics_server_hostname = $puppet_metrics_collector::metrics_server_hostname,
  Optional[Integer] $metrics_server_port     = $puppet_metrics_collector::metrics_server_port,
  Optional[String]  $metrics_server_db_name  = $puppet_metrics_collector::metrics_server_db_name,
  Optional[String]  $override_metrics_command = $puppet_metrics_collector::override_metrics_command,
  ) {
  Puppet_metrics_collector::Pe_metric {
    output_dir     => $puppet_metrics_collector::output_dir,
    scripts_dir    => $puppet_metrics_collector::scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
    override_metrics_command => $override_metrics_command,
  }

  if ($facts['pe_server_version'] =~ NotUndef) and (versioncmp($facts['pe_server_version'], '2018.1.0') < 0) {
    $additional_metrics = [
      { 'name' => 'compiler.find_node',
        'url'  => "puppetserver:name=puppetlabs.${::hostname}.compiler.find_node" },
      { 'name' => 'puppetdb.query',
        'url'  => "puppetserver:name=puppetlabs.${::hostname}.puppetdb.query" },
      { 'name' => 'puppetdb.resource.search',
        'url'  => "puppetserver:name=puppetlabs.${::hostname}.puppetdb.resource.search" },
      { 'name' => 'puppetdb.facts.encode',
        'url'  => "puppetserver:name=puppetlabs.${::hostname}.puppetdb.facts.encode" },
      { 'name' => 'puppetdb.command.submit.replace facts',
        'url'  => "puppetserver:name=puppetlabs.${::hostname}.puppetdb.command.submit.replace facts" },
      { 'name' => 'puppetdb.catalog.munge',
        'url'  => "puppetserver:name=puppetlabs.${::hostname}.puppetdb.catalog.munge" },
      { 'name' => 'puppetdb.command.submit.replace catalog',
        'url'  => "puppetserver:name=puppetlabs.${::hostname}.puppetdb.command.submit.replace catalog" },
      { 'name' => 'puppetdb.report.convert_to_wire_format_hash',
        'url'  => "puppetserver:name=puppetlabs.${::hostname}.puppetdb.report.convert_to_wire_format_hash" },
      { 'name' => 'puppetdb.command.submit.store report',
        'url'  => "puppetserver:name=puppetlabs.${::hostname}.puppetdb.command.submit.store report" },
      ]
  } else {
    $additional_metrics = []
  }

  puppet_metrics_collector::pe_metric { 'puppetserver' :
    metric_ensure           => $metrics_ensure,
    hosts                   => $hosts,
    metrics_port            => $port,
    additional_metrics      => $additional_metrics,
    metrics_server_type     => $metrics_server_type,
    metrics_server_hostname => $metrics_server_hostname,
    metrics_server_port     => $metrics_server_port,
    metrics_server_db_name  => $metrics_server_db_name,
  }
}
