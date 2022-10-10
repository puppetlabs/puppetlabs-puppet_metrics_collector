# Function: hosts_with_pe_profile
#
# Queries PuppetDB for hosts with the specified Puppet Enterprise profile.
# Used by this module to query Puppet Enterprise API endpoints.
# Parameters:
#
# @param profile 
#   the short name of the Puppet Enterprise profile.
# Results:
#
# @return $hosts: an array of certnames. or ['127.0.0.1'] when PuppetDB returns no hosts.
function puppet_metrics_collector::hosts_with_pe_profile($profile) {
  # storeconfigs is used here to determine if PuppetDB is available to query.
  # See: https://github.com/puppetlabs/puppet-enterprise-modules/blob/main/docs/pe-modules-next-discussion-outline.txt
  if $settings::storeconfigs {
    $_profile = capitalize($profile)
  $hosts = puppetdb_query("resources[certname] {
               type = 'Class' and
               title = 'Puppet_enterprise::Profile::${_profile}' and
               nodes { deactivated is null and expired is null }
               order by certname
              }").map |$nodes| { $nodes['certname'] }
  }
  else {
    $hosts = []
  }

  if empty($hosts) {
    $default = $facts['clientcert'] ? {
      undef => '127.0.0.1',
      default => $facts['clientcert']
    }
    [$default]
  }
  else {
    sort($hosts)
  }
}
