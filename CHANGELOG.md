# Minor Release 6.5.0

## Changes:
- The `puppet_metrics_collector` can now be used without requiring the
  installation of additional dependencies, such as `puppetlabs-stdlib`.

# Patch Release 6.4.1

## Changes:
- Standardize cleanup of temp files [#88](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/88)

# Minor Release 6.4.0

## Improvements
- Clean up temp files when metrics_tidy exits cleanly [#86](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/86)
- Enable client ssl cert for metrics [#82](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/82)
- Update to PDK 2.0, Updated Supported Puppet versions, and OS's [#83](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/83)
## Changes:
- Re-enable remote metric collection  [#85](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/85)

# Minor Release 6.3.0

## Improvements
- Update json2timeseriesdb to tag Postgres metrics [#79](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/79)

## Changes:
- Fix psql_metrics error checking [#78](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/78)

# Minor Release 6.2.0

## Improvements
- Gather metrics from pe-postgresql [#71](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/71)
- Add VMware metrics collection [#68](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/68)

## Changes:
- Mbeans that return a 404 will default to null instead of an error [#76](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/76)
- A warning is no longer printed when shipping metrics to a remote database [#75](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/75)
- Fix duplicate declaration of common files [#70](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/70)
- Fix ensure => absent for metrics [#69](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/69)

# Patch Release 6.1.1

## Changes:
 - Fixes a bug where Orchestrator metrics collection used the Puppetserver parameters

# Minor Release 6.1.0

## Improvements
 - Fixes a bug where the tarballs files would contain 90 days worth of files instead of 1
 - Ensure the system metrics can be tidied up
 - Stop pretty-printing the system metrics.
   - [PR #61](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/61)

# Major Release 6.0.0

This is a major release as it drops support for Puppet 4.x and versions of PE
based upon Puppet 4.x. If you are using those unsupported versions of PE, 
continue to use version 5.3.0.

Refer to the README for limitations regarding the collection of remote 
PuppetDB metrics, and a workaround.

If using this module with the Puppet Metrics Dashboard,
upgrade to version 2.2.0 or later of that module.

## Improvements
 - Switch from the v1 to v2 Metrics API for additional metrics (for PuppetDB)
 - Collect ACE and Bolt service metrics
 - Reorganize into service and system classes
 - Move duplicate code from service classes to defined types
 - Move templated per-service tidy scripts to one common 'metrics_tidy' script
 - Simplify the 'create-metrics-archive' script, removing the one constant parameter
 - Do not symlink the 'create-metrics-archive' script to '/opt/puppetlabs/bin/'
 - Store configuration and code in separate 'config' and 'scripts' directories
 - Eliminate the '/opt/puppetlabs/puppet_metrics_collector/bin' directory
 - Add puppet code to delete the resulting legacy directories and files
 - Resolve various puppet-lint and rubocop issues
 - Refactor the shell scripts
 - Merge json2graphite.rb and json2timeseriesdb scripts
 - Update measurement tagging
 - Update to PDK 1.16
 - Update documentation

## Changes
 - Drop support for Puppet 4.x and versions of PE based upon Puppet 4.x
 - Use v2 Metrics API for additional metrics for PuppetDB
 - Change tags to system metrics

# Minor Release 5.3.0

## Improvements
 - Enable FOSS support with Puppetserver collection
   - [PR #23](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/23)
 - Remove `127.0.0.1` special case naming
   - [PR #26](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/26)
 - Add the ability to generate system metrics
   - [PR #28](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/28)
   - [PR #30](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/30)
 - Make the output files smaller by excluding metrics and not pretty printing
   - [PR #29](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/29)

## Changes
 - Add a newline to STDOUT of the processing script
   - [PR #27](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/27)

# Minor Release 5.2.0

## Improvements
 - Add ability to send metrics data directly to influxdb, graphite,
   or splunk ( in combination with the splunk_hec module )
   - https://github.com/puppetlabs/puppetlabs-puppet\_metrics\_collector/pull/19

## Changes
 - Update metadata dependency information to reflect support for
   puppetlabs/stdlib 6.x
   - https://github.com/puppetlabs/puppetlabs-puppet\_metrics\_collector/pull/22

# Patch Release 5.1.2

## Changes:
 - Update metadata dependency information to reflect support for
   puppetlabs/stdlib 5.x
 - Update Changelog terminology to use [semver term](https://semver.org/)
   "Patch", rather than "Z"

# Patch Release 5.1.1

## Changes:
 - Ensure nightly compression of metrics works with a large amount of files
   - https://github.com/puppetlabs/puppetlabs-puppet\_metrics\_collector/pull/8

# Minor Release 5.1.0

## Improvements
 - Auto configure puppetserver and puppetdb hosts
  - https://github.com/puppetlabs/puppetlabs-puppet\_metrics\_collector/pull/5

# Patch Release 5.0.1

## Changes:
 - Convert module to standard PDK format

# Major Release 5.0.0

This major release renames the project and obseletes deprecated parameters that
had previously been preserved for backwards compatiblity. The new name of the
project aligns it with the value it provides, and eliminates long incorrect
technology references to its implementation from the name.

Note: If upgrading to puppet\_metrics\_collector 5.x from a
pe\_metric\_curl\_cron\_jobs version older than 4.6.0, it is recommended that
you deploy pe\_metric\_curl\_cron\_jobs 4.6.0 first, let Puppet run, and then
upgrade to puppet\_metrics\_collector 5.x in order to ensure that all cleanup
and migration work is performed smoothly.

## Changes
 - Rename the project from "pe\_metric\_curl\_cron\_jobs" to "puppet\_metrics\_collector"
 - Remove deprecated parameters
   - puppet\_metrics\_collector::puppet\_server\_hosts (long deprecated in favor of puppet\_metrics\_collector::puppetserver\_hosts)
   - puppet\_metrics\_collector::puppet\_server\_port (long deprecated in favor of puppet\_metrics\_collector::puppetserver\_port)

# Minor Release 4.6.0

## Improvements:
 - Add PuppetDB HA Metrics
   - [PR #46](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/46)

# Minor Release 4.5.0

## Improvements:
 - Add a script to zip up metrics for sharing
   - [PR #41](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/41)

# Patch Release 4.4.2

## Bug Fixes:
 - Tidy script does not work without bzip (not installed on RHEL 7 by default)
   - The tidy script now uses gzip which is more regularly available
   - [PR #45](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/45)
 - Tidy script would not exit on error
   - [PR #43](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/43)
 - Config file could change every run if you use puppetdb_query to find the hosts
   - [PR #42](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/42)

# Patch Release 4.4.1

## Bug Fixes:
 - PuppetDB metrics could not be gathered by default in PE < 2016.4.0
   - [PR #39](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/39)

# Minor Release 4.4.0

## Improvements
  - Allow connecting over http instead of https for PuppetDB
    - [PR #37](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/37)
    - In order to use pass `--no-ssl` and `--metrics_port` to the tk_metrics script

# Minor Release 4.3.0

## Improvements
  - No longer pass certificates to connect to metrics endpoint
    - [PR #34](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/34)

# Patch Release 4.2.2

## Bug Fixes:
 - Tidy cron jobs would only delete metric files exactly retention_days away
   - [PR #33](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/33)

# Patch Release 4.2.1

## Bug Fixes:
 - PE versions < 2016.2 now GET each metric individually instead of using a POST
   - [PR #30](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/30)

# Minor Release 4.2.0

## Improvements
 - Allow not saving a metrics file
   - Add a `--output-dir` CLI argument to metrics scripts which tells the script
   where to save metrics output to.
   - If `--output-dir` is not specified then no file is saved
 - Metrics scripts print to STDOUT by default
   - Use `--no-print` to silence output to STDOUT

# Minor Release 4.1.0

## Improvements
 - Retrieve all additional metrics with one POST instead of multiple GETs
   - [PR #23](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/23)
 - Add a `--print` command line argument to the metrics scripts
   - This allows for integrations with other tools that can read the output from stdout.
   - [PR #24](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/24)
 - Move script configuration into a YAML file
   - Allow the metrics scripts to be stored as static files instead of templates
   - [PR #25](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/25)

# Major Release 4.0.0

This is a major release because some of the PuppetDB metrics are renamed.
For most users this update is only additive, however, if you are post processing
the output of the module then you may need to update to the new names of the metrics.

## Changes
 - Rename some PuppetDB metrics
   - command_processing_time is now global_processing_time
   - command_processed is now global_processed
   - replace_catalog_time is now storage_replace-catalog-time
   - replace_facts_time is now storage_replace-facts-time
   - store_report_time is now storage_store-report-time
   - *\_retry and *\_retry-counts metrics are renamed to include mq\_ at the front

## Improvements
 - We now collect the output of the status endpoint for orchestrator
 - We now collect HakariCP connection pooling metrics for PuppetDB
 - We now collect the global metrics for PuppetDB
 - We now collect the storage metrics for PuppetDB
 - Each component now has its own class to allow customizing parameters per
  component

# Patch Release 3.0.1

## Bug Fixes:
 - Stagger compression of files between midnight and 3AM to prevent a CPU spike
   - [PR #22](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/22)

# Major Release 3.0.0

## Changes
 - Every parameter, file name, etc... that contained puppet_server is rewritten
 to puppetserver
   - The existing parameters remain but are deprecated and should not be used
 - Metric storage format is a single JSON blob instead of the exact output from
 whichever endpoint was queried

## Improvements
 - Metrics gathering scripts are rewritten in ruby
 - Metrics are now stored in one file per component
   - PuppetDB metrics were previously stored with one file per metric
   - Metrics are now stored in one directory per server
 - PuppetDB metrics now gathers the status endpoint
   - This is the preferred way to get the queue_depth metric
 - Opt-in collection of ActiveMQ metrics is available
 - Metrics are compressed daily for a 90% reduction in disk space
   - Metrics are retained for 90 days by default instead of 3 days
     - Retained metrics still take less space due to compression savings

## Bug Fixes:
 - The metrics tidy cron job previously ran every minute between 2-3 AM.
It now runs just once at 2AM.
