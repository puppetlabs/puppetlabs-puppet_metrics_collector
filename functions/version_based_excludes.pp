# Function: version_based_excludes
#
# Description: Generates a list of services to exlude based on version of PE
# @param metrics_type the service currently compiling metrics for
# @return excludes the list of services to exclude
function puppet_metrics_collector::version_based_excludes(
  String[1] $metrics_type,
) >> Array[String] {
  case $metrics_type {
    'puppetserver': {
      $excludes = ($facts['pe_server_version'] =~ NotUndef and versioncmp($facts['pe_server_version'], '2017.3.0') >= 0) ? {
        true    => ['file-sync-storage-service','pe-puppet-profiler','pe-master','pe-jruby-metrics'],
        default => ['file-sync-storage-service'],
      }
    }
    default: {
      $excludes = []
    }
  }

  return $excludes
}
