# Function: hosts_with_pe_profile
#
# Queries PuppetDB for hosts with the specified Puppet Enterprise profile.
# Used by this module to query Puppet Enterprise API endpoints.

# Parameters:
#
# $profile: the short name of the Puppet Enterprise profile.

# Results:
#
# $hosts: an array of certnames.
#
# Replaces the certname with '127.0.0.1' when the certname matches the localhost.
# Returns ['127.0.0.1'] when PuppetDB returns no hosts.

function puppet_metrics_collector::hosts_with_pe_profile($profile) {
  if $settings::storeconfigs {
    $_profile = capitalize($profile)
    $hosts = puppetdb_query("resources[certname] {
               type = 'Class' and
               title = 'Puppet_enterprise::Profile::${_profile}' and
               nodes { deactivated is null and expired is null }
              }").map |$nodes| {
                if $nodes['certname'] == $settings::certname {
                  '127.0.0.1'
                } else {
                  $nodes['certname']
                }
    }
  } else {
    $hosts = []
  }
  if empty($hosts) {
    ['127.0.0.1']
  } else {
    sort($hosts)
  }
}
