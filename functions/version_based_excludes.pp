# Function: version_based_excludes
#
# Description: Generates a list of services to exlude based on the metrics type
# @param metrics_type the service currently compiling metrics for
# @return excludes the list of services to exclude
function puppet_metrics_collector::version_based_excludes(
  String[1] $metrics_type,
) >> Array[String] {
  if $metrics_type == 'puppetserver' {
    ['file-sync-storage-service','pe-puppet-profiler','pe-master','pe-jruby-metrics']
  }
  else {
    $excludes = []
  }
}
