class puppet_metrics_collector::puppetserver (
  Integer       $collection_frequency = $puppet_metrics_collector::collection_frequency,
  Integer       $retention_days       = $puppet_metrics_collector::retention_days,
  String        $metrics_ensure       = $puppet_metrics_collector::puppetserver_metrics_ensure,
  Array[String] $hosts                = $puppet_metrics_collector::puppetserver_hosts,
  Integer       $port                 = $puppet_metrics_collector::puppetserver_port,
) {
  Puppet_metrics_collector::Pe_metric {
    output_dir     => $puppet_metrics_collector::output_dir,
    scripts_dir    => $puppet_metrics_collector::scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
  }

  puppet_metrics_collector::pe_metric { 'puppetserver' :
    metric_ensure => $metrics_ensure,
    hosts         => $hosts,
    metrics_port  => $port,
  }
  
  if $facts['pe_server_version'] < 2018.1.0 {
  
    Pe_metric_curl_cron_jobs::Pe_metric <| title == 'puppetserver' |> {
      additional_metrics => [
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
      ],
    }
  }

}
