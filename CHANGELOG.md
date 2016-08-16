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
