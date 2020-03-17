# Collect ActiveMQ Metrics
class puppet_metrics_collector::service::activemq (
  String                  $metrics_ensure           = $puppet_metrics_collector::activemq_metrics_ensure,
  Integer                 $collection_frequency     = $puppet_metrics_collector::collection_frequency,
  Integer                 $retention_days           = $puppet_metrics_collector::retention_days,
  Array[String]           $hosts                    = $puppet_metrics_collector::activemq_hosts,
  Integer                 $port                     = $puppet_metrics_collector::activemq_port,
  Optional[String]        $override_metrics_command = $puppet_metrics_collector::override_metrics_command,
  Optional[Array[String]] $excludes                 = $puppet_metrics_collector::activemq_excludes,
  Optional[Enum['influxdb', 'graphite', 'splunk_hec']] $metrics_server_type = $puppet_metrics_collector::metrics_server_type,
  Optional[String]        $metrics_server_hostname  = $puppet_metrics_collector::metrics_server_hostname,
  Optional[Integer]       $metrics_server_port      = $puppet_metrics_collector::metrics_server_port,
  Optional[String]        $metrics_server_db_name   = $puppet_metrics_collector::metrics_server_db_name,
) {
  # lint:ignore:140chars
  $additional_metrics = [
    {
      'type'      => 'read',
      'mbean'     => 'java.lang:type=Memory',
      'attribute' => 'HeapMemoryUsage,NonHeapMemoryUsage'
    },
    {
      'type'      => 'read',
      'mbean'     => 'java.lang:name=*,type=GarbageCollector',
      'attribute' => 'CollectionCount'
    },
    {
      'type'      => 'read',
      'mbean'     => 'java.lang:type=Runtime',
      'attribute' => 'Uptime'
    },
    {
      'type'      => 'read',
      'mbean'     => 'java.lang:type=OperatingSystem',
      'attribute' => 'OpenFileDescriptorCount,MaxFileDescriptorCount'
    },
    {
      'type'      => 'read',
      'mbean'     => 'org.apache.activemq:brokerName=*,type=Broker',
      'attribute' => 'MemoryLimit,MemoryPercentUsage,CurrentConnectionsCount'
    },
    {
      'type'      => 'read',
      'mbean'     => 'org.apache.activemq:type=Broker,brokerName=*,destinationType=Queue,destinationName=mcollective.*',
      'attribute' => 'AverageBlockedTime,AverageEnqueueTime,AverageMessageSize,ConsumerCount,DequeueCount,DispatchCount,EnqueueCount,ExpiredCount,ForwardCount,InFlightCount,ProducerCount,QueueSize',
    },
    {
      'type'      => 'read',
      'mbean'     => 'org.apache.activemq:type=Broker,brokerName=*,destinationType=Topic,destinationName=mcollective.*.agent',
      'attribute' => 'AverageBlockedTime,AverageEnqueueTime,AverageMessageSize,ConsumerCount,DequeueCount,DispatchCount,EnqueueCount,ExpiredCount,ForwardCount,InFlightCount,ProducerCount,QueueSize',
    },
  ]
  # lint:endignore

  file { "${puppet_metrics_collector::scripts_dir}/amq_metrics" :
    ensure => $metrics_ensure,
    mode   => '0755',
    source => 'puppet:///modules/puppet_metrics_collector/amq_metrics',
  }

  puppet_metrics_collector::pe_metric { 'activemq' :
    metric_ensure            => $metrics_ensure,
    cron_minute              => "*/${collection_frequency}",
    retention_days           => $retention_days,
    hosts                    => $hosts,
    metrics_port             => $port,
    metric_script_file       => 'amq_metrics',
    override_metrics_command => $override_metrics_command,
    excludes                 => $excludes,
    additional_metrics       => $additional_metrics,
    metrics_server_type      => $metrics_server_type,
    metrics_server_hostname  => $metrics_server_hostname,
    metrics_server_port      => $metrics_server_port,
    metrics_server_db_name   => $metrics_server_db_name,
  }
}
