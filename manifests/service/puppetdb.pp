# @summary Collects puppetdb metrics
#
# @api private
#
class puppet_metrics_collector::service::puppetdb (
  String                  $metrics_ensure           = $puppet_metrics_collector::puppetdb_metrics_ensure,
  Integer                 $collection_frequency     = $puppet_metrics_collector::collection_frequency,
  Integer                 $retention_days           = $puppet_metrics_collector::retention_days,
  Array[String]           $hosts                    = $puppet_metrics_collector::puppetdb_hosts,
  Integer                 $port                     = $puppet_metrics_collector::puppetdb_port,
  Array[Hash]             $extra_metrics            = [],
  Optional[String]        $override_metrics_command = $puppet_metrics_collector::override_metrics_command,
  Optional[Array[String]] $excludes                 = $puppet_metrics_collector::puppetdb_excludes,
  Optional[Enum['influxdb', 'graphite', 'splunk_hec']] $metrics_server_type = $puppet_metrics_collector::metrics_server_type,
  Optional[String]        $metrics_server_hostname  = $puppet_metrics_collector::metrics_server_hostname,
  Optional[Integer]       $metrics_server_port      = $puppet_metrics_collector::metrics_server_port,
  Optional[String]        $metrics_server_db_name   = $puppet_metrics_collector::metrics_server_db_name,
) {
  puppet_metrics_collector::deprecated_parameter { 'puppet_metrics_collector::service::puppetdb::metrics_server_type': }
  puppet_metrics_collector::deprecated_parameter { 'puppet_metrics_collector::service::puppetdb::metrics_server_hostname': }
  puppet_metrics_collector::deprecated_parameter { 'puppet_metrics_collector::service::puppetdb::metrics_server_port': }
  puppet_metrics_collector::deprecated_parameter { 'puppet_metrics_collector::service::puppetdb::metrics_server_db_name': }

  $base_metrics = [
    {
      'type'  => 'read',
      'name'  => 'global_command-parse-time',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.command-parse-time'
    },
    {
      'type'  => 'read',
      'name'  => 'global_discarded',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.discarded'
    },
    {
      'type'  => 'read',
      'name'  => 'global_fatal',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.fatal'
    },
    { # This counter doesn't exist until a failure occurs.
      'type'  => 'read',
      'name'  => 'global_generate-retry-message-time',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.generate-retry-message-time'
    },
    {
      'type'  => 'read',
      'name'  => 'global_message-persistence-time',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.message-persistence-time'
    },
    {
      'type'  => 'read',
      'name'  => 'global_retried',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.retried'
    },
    {
      'type'  => 'read',
      'name'  => 'global_retry-counts',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.retry-counts'
    },
    { # This counter doesn't exist until a failure occurs.
      'type'  => 'read',
      'name'  => 'global_retry-persistence-time',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.retry-persistence-time'
    },
    {
      'type'  => 'read',
      'name'  => 'global_seen',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.seen'
    },
    {
      'type'  => 'read',
      'name'  => 'global_processed',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.processed'
    },
    {
      'type'  => 'read',
      'name'  => 'global_processing-time',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.processing-time'
    },
    {
      'type'  => 'read',
      'name'  => 'global_ignored',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.ignored'
    },
    {
      'type'  => 'read',
      'name'  => 'global_invalidated',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.invalidated'
    },
    {
      'type'  => 'read',
      'name'  => 'global_queue-time',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.queue-time'
    },
    {
      'type'  => 'read',
      'name'  => 'global_awaiting-retry',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.awaiting-retry'
    },
    {
      'type'  => 'read',
      'name'  => 'global_command-size',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.size'
    },
    {
      'type'  => 'read',
      'name'  => 'global_concurrent-depth',
      'mbean' => 'puppetlabs.puppetdb.mq:name=global.concurrent-depth'
    },
    {
      'type'  => 'read',
      'name'  => 'jetty-queuedthreadpool',
      'mbean' => 'org.eclipse.jetty.util.thread:id=*,type=queuedthreadpool'
    },
  ]

  $storage_metrics = [
    {
      'type'  => 'read',
      'name'  => 'storage_add-edges',
      'mbean' => 'puppetlabs.puppetdb.storage:name=add-edges'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_add-resources',
      'mbean' => 'puppetlabs.puppetdb.storage:name=add-resources'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_catalog-hash',
      'mbean' => 'puppetlabs.puppetdb.storage:name=catalog-hash'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_catalog-hash-match-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=catalog-hash-match-time'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_catalog-hash-miss-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=catalog-hash-miss-time'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_gc-catalogs-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=gc-catalogs-time'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_gc-environments-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=gc-environments-time'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_gc-fact-paths',
      'mbean' => 'puppetlabs.puppetdb.storage:name=gc-fact-paths'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_gc-params-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=gc-params-time'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_gc-report-statuses',
      'mbean' => 'puppetlabs.puppetdb.storage:name=gc-report-statuses'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_gc-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=gc-time'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_new-catalog-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=new-catalog-time'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_new-catalogs',
      'mbean' => 'puppetlabs.puppetdb.storage:name=new-catalogs'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_replace-catalog-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=replace-catalog-time'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_replace-facts-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=replace-facts-time'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_resource-hashes',
      'mbean' => 'puppetlabs.puppetdb.storage:name=resource-hashes'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_store-report-time',
      'mbean' => 'puppetlabs.puppetdb.storage:name=store-report-time'
    },
  ]

  # TODO: Track these on a less frequent cadence because they are slow to run

  $storage_metrics_db_queries = [
    {
      'type'  => 'read',
      'name'  => 'storage_catalog-volitilty',
      'mbean' => 'puppetlabs.puppetdb.storage:name=catalog-volitilty'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_duplicate-catalogs',
      'mbean' => 'puppetlabs.puppetdb.storage:name=duplicate-catalogs'
    },
    {
      'type'  => 'read',
      'name'  => 'storage_duplicate-pct',
      'mbean' => 'puppetlabs.puppetdb.storage:name=duplicate-pct'
    },
  ]

  $version = { 'catalogs' => 9, 'facts' => 5, 'reports' => 8, 'deactivate' => 3, 'inputs' => 1 }

  $version_specific_metrics = [
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_retried',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog.${version['catalogs']}.retried"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_retry-counts',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog.${version['catalogs']}.retry-counts"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_size',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog.${version['catalogs']}.size"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_processing-time',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog.${version['catalogs']}.processing-time"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_processed',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog.${version['catalogs']}.processed"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_inputs_retried',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog inputs.${version['inputs']}.retried"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_inputs_retry-counts',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog inputs.${version['inputs']}.retry-counts"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_inputs_ize',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog inputs.${version['inputs']}.size"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_inputs_processing-time',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog inputs.${version['inputs']}.processing-time"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_catalog_inputs_processed',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace catalog inputs.${version['inputs']}.processed"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_facts_retried',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace facts.${version['facts']}.retried"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_facts_retry-counts',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace facts.${version['facts']}.retry-counts"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_facts_size',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace facts.${version['facts']}.size"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_facts_processing-time',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace facts.${version['facts']}.processing-time"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_replace_facts_processed',
      'mbean' => "puppetlabs.puppetdb.mq:name=replace facts.${version['facts']}.processed"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_store_report_retried',
      'mbean' => "puppetlabs.puppetdb.mq:name=store report.${version['reports']}.retried"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_store_reports_retry-counts',
      'mbean' => "puppetlabs.puppetdb.mq:name=store report.${version['reports']}.retry-counts"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_store_reports_size',
      'mbean' => "puppetlabs.puppetdb.mq:name=store report.${version['reports']}.size"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_store_reports_processing-time',
      'mbean' => "puppetlabs.puppetdb.mq:name=store report.${version['reports']}.processing-time"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_store_reports_processed',
      'mbean' => "puppetlabs.puppetdb.mq:name=store report.${version['reports']}.processed"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_deactivate_node_processed',
      'mbean' => "puppetlabs.puppetdb.mq:name=deactivate node.${version['deactivate']}.processed"
    },
    {
      'type'  => 'read',
      'name'  => 'mq_deactivate_node_processing-time',
      'mbean' => "puppetlabs.puppetdb.mq:name=deactivate node.${version['deactivate']}.processing-time"
    }
  ]

  $connection_pool_metrics = [
    {
      'type'  => 'read',
      'name'  => 'PDBReadPool_pool_ActiveConnections',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.ActiveConnections'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBReadPool_pool_IdleConnections',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.IdleConnections'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBReadPool_pool_PendingConnections',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.PendingConnections'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBReadPool_pool_TotalConnections',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.TotalConnections'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBReadPool_pool_Usage',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.Usage'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBReadPool_pool_Wait',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.Wait'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBWritePool_pool_ActiveConnections',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.ActiveConnections'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBWritePool_pool_IdleConnections',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.IdleConnections'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBWritePool_pool_PendingConnections',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.PendingConnections'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBWritePool_pool_TotalConnections',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.TotalConnections'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBWritePool_pool_Usage',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.Usage'
    },
    {
      'type'  => 'read',
      'name'  => 'PDBWritePool_pool_Wait',
      'mbean' => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.Wait'
    },
  ]

  $ha_sync_metrics = [
    {
      'type'  => 'read',
      'name'  => 'ha_last-sync-succeeded',
      'mbean' => 'puppetlabs.puppetdb.ha:name=last-sync-succeeded'
    },
    {
      'type'  => 'read',
      'name'  => 'ha_seconds-since-last-successful-sync',
      'mbean' => 'puppetlabs.puppetdb.ha:name=seconds-since-last-successful-sync'
    },
    { # This counter doesn't exist until a failure occurs.
      'type'  => 'read',
      'name'  => 'ha_failed-request-counter',
      'mbean' => 'puppetlabs.puppetdb.ha:name=failed-request-counter'
    },
    {
      'type'  => 'read',
      'name'  => 'ha_sync-duration',
      'mbean' => 'puppetlabs.puppetdb.ha:name=sync-duration'
    },
    {
      'type'  => 'read',
      'name'  => 'ha_catalogs-sync-duration',
      'mbean' => 'puppetlabs.puppetdb.ha:name=catalogs-sync-duration'
    },
    {
      'type'  => 'read',
      'name'  => 'ha_reports-sync-duration',
      'mbean' => 'puppetlabs.puppetdb.ha:name=reports-sync-duration'
    },
    {
      'type'  => 'read',
      'name'  => 'ha_factsets-sync-duration',
      'mbean' => 'puppetlabs.puppetdb.ha:name=factsets-sync-duration'
    },
    {
      'type'  => 'read',
      'name'  => 'ha_nodes-sync-duration',
      'mbean' => 'puppetlabs.puppetdb.ha:name=nodes-sync-duration'
    },
    {
      'type'  => 'read',
      'name'  => 'ha_record-transfer-duration',
      'mbean' => 'puppetlabs.puppetdb.ha:name=record-transfer-duration'
    },
  ]

  $additional_metrics = $base_metrics + $storage_metrics + $connection_pool_metrics +
  $version_specific_metrics + $ha_sync_metrics + $extra_metrics

  $ssl = $hosts ? {
    ['127.0.0.1'] => false,
    default       => true,
  }

  if $port == 8081 and $ssl == false {
    $_port = 8080
  } else {
    $_port = $port
  }

  puppet_metrics_collector::pe_metric { 'puppetdb' :
    metric_ensure            => $metrics_ensure,
    cron_minute              => "0/${collection_frequency}",
    retention_days           => $retention_days,
    hosts                    => $hosts,
    metrics_port             => $_port,
    ssl                      => $ssl,
    override_metrics_command => $override_metrics_command,
    excludes                 => $excludes,
    additional_metrics       => $additional_metrics,
    metrics_server_type      => $metrics_server_type ? {
      'splunk_hec' => 'splunk_hec',
      default      => undef,
    },
  }
}
