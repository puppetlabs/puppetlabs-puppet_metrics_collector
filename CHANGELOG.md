## Release 2.0.0

### Summary

Major release of the Support Script bundled with PE 2016.5.0.

### Features

  - The support script is now distributed to agent nodes via pluginsync.
    This is made possible by changes in PE 2016.5.0 which migrated other PE
    modules to the `puppet infrastructure` subcommand, which allows the
    support script to take sole ownership of the `puppet enterprise`
    subcommand.

  - All improvements and bugfixes from version 1.2.0.

### Breaking Changes

  - This version of the module requires PE 2016.5.0 or newer.

  - In order to support pluginsync, the support script has moved from:

      files/puppet-enterprise-support

    to:

      lib/puppet_x/puppetlabs/support_script/v1/puppet-enterprise-support.sh


## Release 1.2.0

### Summary

Feature release of the Support Script bundled with PE 2016.4.3.

### Features

  - Support Script gathers MCollective peadmin client configuration and logs
    from: /var/lib/peadmin

  - Support Script gathers PostgreSQL settings from:

      /opt/puppetlabs/server/data/postgresql/<version>/data/postgresql.conf

### Bug Fixes

  - A one minute timeout has been added to the check that gathers output
    from the PuppetDB summary-stats endpoint. For large databases, this
    operation can take tens of minutes.

  - Support script checks against PE server components are now conditional
    on the packages that provide those components being installed.


## Release 1.1.0

### Summary

Feature release of the Support Script bundled with PE 2016.4.0.

### Features

  - Support Script gathers output from the Puppet Server `status/v1/services`
    endpoint at debug level. This information is useful for troubleshooting
    Puppet Server performance issues.

  - Support Script gathers output from the Puppet Server `puppet/v3/environments`
    endpoint. This information is useful for troubleshooting modulepath and
    class synchronization issues.

### Bug Fixes

  - R10k checks now use the proper configuration file if Code Manager is enabled.


## Release 1.0.0

### Summary

First major release of the Support Script as a stand-alone module. This version
was bundled with PE 2016.2.0 with support for diagnosing PE infrastructure
installations, not agents.

### Features
  - Support Script extracted from the legacy PE installer repository and
    available as a stand-alone module. Script functionality is accessed through
    a new Puppet subcommand: `puppet enterprise support`

  - Support script archives now include the platform hostname and archive
    datestamps are in UTC. A `metadata.json` file has been added to enable
    automated parsing of support script contents.

  - The scope of configuration files gathered from `/etc/puppetlabs` has been
    clearly defined and sanitization of sensitive data has been improved.

  - Multiple small cleanups of diagnostic functions.

### Bug Fixes
  - Console status check timeout has been increased from 5 seconds to 60
    seconds.
