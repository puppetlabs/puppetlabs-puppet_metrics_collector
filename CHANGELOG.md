## Release 2.2.0

### Summary

Feature release of the Support Script bundled with PE 2017.2.0.

### Features

  - A list of active nodes is gathered from the Orchestrator inventory
    API along with the PuppetDB nodes dataset.

  - All improvements and bugfixes from version 1.4.0.


## Release 2.1.0

### Summary

Feature release of the Support Script bundled with PE 2016.5.2 and 2017.1.0.

### Features

  - All improvements and bugfixes from version 1.3.0.

### Bug Fixes

  - Support script help now includes a note that some old enterprise
    subcommands moved to the puppet infrastructure command.


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


## Release 1.5.0

### Summary

Feature release of the Support Script bundled with PE 2016.4.6.

### Features

  - Information on installed modules is now captured in YAML format.

  - Output from dmesg is captured along with system logs.

  - Disk space checks now take the size of log and metrics data
    into account.

  - Package manager configuration related to PE is now captured.

### Removals

  - Ubuntu 12.04 has been dropped from the test matrices. This follows the
    removal of 12.04 as a supported platform in PE 2016.4.5.

### Bug Fixes

  - Debug logs have been restored to Facter output.


## Release 1.4.0

### Summary

Feature release of the Support Script bundled with PE 2016.4.5.

### Features

  - The `puppet enterprise support` command now takes an optional `--ticket`
    flag that can be used to add a ticket number to the output filename
    and metadata.

  - Per-environment environment.conf and hiera.yaml files are now captured
    to aid with the troubleshooting of directory environment settings and
    Hiera 4/Hiera 5 features.

  - The facter.conf file is now collected along with other items from
    /etc/puppetlabs.

### Bug Fixes

  - Service status is now captured on OS versions that use systemd instead of
    just RedHat SysV init.

  - The puppet-agent package is now included in queries for the status
    of PE packages.


## Release 1.3.0

### Summary

Feature release of the Support Script bundled with PE 2016.4.3.

### Features

  - Support script output now contains a couple of additional symlinks that
    add compatibility with the SOScleaner tool. This tool can obfuscate
    hostname and IP information from Support Script tarballs.

  - Logs for PE services are collected from journalctl when available.

  - Gems installed via Puppet ruby or Puppetserver JRuby are listed along
    with version numbers.

  - The puppet log directory has been added to `find -ls` output.

  - ps stats now capture %cpu and %mem.

  - A DB query for thundering agent herds is run if PE Postgres is installed.

  - The output of the Orchestration Services status/ endpoint is collected.

  - Metrics produced by the pe_metric_curl_cron_jobs module are collected
    if available.

  - Additional configuration files are collected from PE Postgres along with
    the runtime values of Postgres settings.

### Bug Fixes

  - Support script archive creation has been updated to use one pipelined
    command instead of two separate commands. This reduces the amount of
    temporary disk space needed to create the final output.


## Release 1.2.0

### Summary

Feature release of the Support Script. Not included in any PE release.

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
