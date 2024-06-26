# Function: version_based_excludes
#
# Description: Generates a list of services to exlude based on the metrics type
# @param metrics_type the service currently compiling metrics for
# @return excludes the list of services to exclude
function puppet_metrics_collector::version_based_excludes(
  String[1] $metrics_type,
) >> Array[String] {
  case $metrics_type {
    'puppetserver': {
      # File Sync Storage includes a lot of detail that bloats file sizes.
      # The pe-* metrics are legacy representations that only duplicate data.
      ['file-sync-storage-service','pe-puppet-profiler','pe-master','pe-jruby-metrics']
    }
    'console': {
      # PE Console has a lot of parameterized routes that can result in
      # hundreds of megabytes collected daily from the route metrics.
      # This data can be extracted from the console access log if needed.
      ['comidi-route-metrics']
    }
    default: {
      []
    }
  }
}
