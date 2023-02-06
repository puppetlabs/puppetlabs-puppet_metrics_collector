# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v7.2.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v7.2.0) (2023-02-06)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v7.1.1...v7.2.0)

### Added

- \(SUP-3535\) Add more sar metrics to collect [\#176](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/176) ([m0dular](https://github.com/m0dular))
- \(SUP-2115\) Add postgres bloat size and percents [\#175](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/175) ([m0dular](https://github.com/m0dular))
- \(SUP-3881\) Add collection for PE console services [\#174](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/174) ([m0dular](https://github.com/m0dular))
- \(SUP-2736\) Documentation [\#170](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/170) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-2736\) Add puppet string documentation [\#168](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/168) ([elainemccloskey](https://github.com/elainemccloskey))

### Fixed

- \(SUP-3875\) Consider /sbin for runuser path [\#172](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/172) ([m0dular](https://github.com/m0dular))

## [v7.1.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v7.1.1) (2022-09-29)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v7.1.0...v7.1.1)

### Fixed

- \(SUP-3681\) Check for valid status key in metrics [\#166](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/166) ([m0dular](https://github.com/m0dular))
- \(SUP-2734\) Collection to use FQDN to connect to the PuppetDB instance when runni… [\#163](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/163) ([elainemccloskey](https://github.com/elainemccloskey))

## [v7.1.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v7.1.0) (2022-07-19)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v7.0.5...v7.1.0)

### Added

- \(SUP-3472\) Add file sync storage metric collection [\#160](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/160) ([jarretlavallee](https://github.com/jarretlavallee))

### Fixed

- \(GH-154\) Switch from change time to modify time [\#155](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/155) ([MirandaStreeter](https://github.com/MirandaStreeter))

## [v7.0.5](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v7.0.5) (2021-10-12)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v7.0.4...v7.0.5)

### Fixed

- \(SUP-2725\) Fix system collection frequency [\#150](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/150) ([m0dular](https://github.com/m0dular))

## [v7.0.4](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v7.0.4) (2021-09-30)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v7.0.3...v7.0.4)

### Fixed

- \(SUP-2682\) Remove Requires= property from timers [\#146](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/146) ([m0dular](https://github.com/m0dular))

## [v7.0.3](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v7.0.3) (2021-07-20)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v7.0.2...v7.0.3)

### Fixed

- \(maint\) Change default for hosts\_with\_pe\_profile when storeconfigs is false [\#141](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/141) ([nmburgan](https://github.com/nmburgan))

## [v7.0.2](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v7.0.2) (2021-07-19)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v7.0.1...v7.0.2)

### Fixed

- Remove system warning entirely [\#139](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/139) ([m0dular](https://github.com/m0dular))

## [v7.0.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v7.0.1) (2021-07-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v7.0.0...v7.0.1)

### Fixed

- Change system notify to warning function [\#131](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/131) ([m0dular](https://github.com/m0dular))

## [v7.0.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v7.0.0) (2021-07-02)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v6.6.0...v7.0.0)

### Changed

- \(SUP-2493\) Remove support for SysVinit operating systems [\#121](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/121) ([jarretlavallee](https://github.com/jarretlavallee))
- \(SUP-2493\) Remove Puppet 5.x support [\#120](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/120) ([jarretlavallee](https://github.com/jarretlavallee))
- \(GH-108\) Disable sysstat management by default [\#116](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/116) ([jarretlavallee](https://github.com/jarretlavallee))
- Remove collection of AMQ metrics [\#111](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/111) ([m0dular](https://github.com/m0dular))
- SUP-2192 Migration from Cron, to SystemD timers for Database Maintenance  [\#99](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/99) ([m0dular](https://github.com/m0dular))

### Added

- Addition of SLES 12 Test Platform [\#125](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/125) ([MartyEwings](https://github.com/MartyEwings))
- Add PuppetDB message queue metrics [\#112](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/112) ([jarretlavallee](https://github.com/jarretlavallee))
- \(SUP-1969\) Enable metrics shipping for all system types [\#94](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/94) ([jarretlavallee](https://github.com/jarretlavallee))

### Fixed

- Rework namevar of defined types [\#114](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/114) ([m0dular](https://github.com/m0dular))
- \(GH-95\) Use -I with pidstat with system\_processes [\#96](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/96) ([jarretlavallee](https://github.com/jarretlavallee))

## [v6.6.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v6.6.0) (2021-06-02)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v6.5.0...v6.6.0)

### Added

- Add PuppetDB Jetty thread metrics [\#103](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/103) ([jarretlavallee](https://github.com/jarretlavallee))
- Expose additional\_metrics for each service [\#102](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/102) ([jarretlavallee](https://github.com/jarretlavallee))
- Add concurrent-depth to PuppetDB metrics [\#101](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/101) ([jarretlavallee](https://github.com/jarretlavallee))

## [v6.5.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v6.5.0) (2021-04-19)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v6.4.1...v6.5.0)

### Added

- \(PE-31763\) Remove the dependency on stdlib [\#90](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/90) ([jarretlavallee](https://github.com/jarretlavallee))

## [v6.4.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v6.4.1) (2021-04-08)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/v6.4.0...v6.4.1)

### Fixed

- Standardize cleanup of temp files [\#88](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/88) ([m0dular](https://github.com/m0dular))

## [v6.4.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/v6.4.0) (2021-04-07)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/6.3.0...v6.4.0)

### Added

- \(PE-31705\) Re-enable remote metric collection [\#85](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/85) ([Sharpie](https://github.com/Sharpie))
- \(GH-81\) Enable client ssl cert for metrics [\#82](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/82) ([jarretlavallee](https://github.com/jarretlavallee))

### Fixed

- Clean up temp files when metrics\_tidy exits cleanly [\#86](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/86) ([brontitall](https://github.com/brontitall))

## [6.3.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/6.3.0) (2021-02-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/6.2.0...6.3.0)

### Added

- \(SUP-2195\) Update json2timeseriesdb to tag Postgres metrics [\#79](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/79) ([Sharpie](https://github.com/Sharpie))

### Fixed

- Fix psql\_metrics error checking [\#78](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/78) ([Sharpie](https://github.com/Sharpie))

## [6.2.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/6.2.0) (2020-12-29)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/6.1.1...6.2.0)

### Added

- \(SUP-2058\) Gather metrics from pe-postgresql [\#71](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/71) ([Sharpie](https://github.com/Sharpie))
- \(SUP-2054\) Add VMware metrics collection [\#68](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/68) ([Sharpie](https://github.com/Sharpie))

### Fixed

- \(GH-74\) Return null when a mbean is missing [\#76](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/76) ([jarretlavallee](https://github.com/jarretlavallee))
- \(gh-73\) Append - to the metric command for json2timeseriesdb [\#75](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/75) ([jarretlavallee](https://github.com/jarretlavallee))
- Fix duplicate declaration of common files [\#70](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/70) ([Sharpie](https://github.com/Sharpie))
- Fix ensure =\> absent for metrics [\#69](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/69) ([Sharpie](https://github.com/Sharpie))

## [6.1.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/6.1.1) (2020-09-14)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/6.1.0...6.1.1)

### Fixed

- Getting orchestrator paramaters to use correct values, not puppetserver's [\#65](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/65) ([MirandaStreeter](https://github.com/MirandaStreeter))
- Allow for coalescing boolean values [\#63](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/63) ([jarretlavallee](https://github.com/jarretlavallee))

## [6.1.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/6.1.0) (2020-07-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/6.0.0...6.1.0)

### Added

- Reduce the size of files on disk [\#61](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/61) ([jarretlavallee](https://github.com/jarretlavallee))

## [6.0.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/6.0.0) (2020-03-20)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/5.3.0...6.0.0)

### Added

- \(PE-28451\) switch from the v1 to v2 metrics api [\#57](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/57) ([tkishel](https://github.com/tkishel))
- Better error handling in tidy script [\#52](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/52) ([m0dular](https://github.com/m0dular))
- \(PIE-178\) Print metrics as line-delimited JSON [\#44](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/44) ([Sharpie](https://github.com/Sharpie))
- \(maint\) normalize json2graphite.rb and json2timeseriesdb [\#37](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/37) ([tkishel](https://github.com/tkishel))
- \(PE-27794\) collect data from ace and bolt \(puma\) services [\#36](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/36) ([tkishel](https://github.com/tkishel))
- \(SLV-631\) add process tracking [\#35](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/35) ([RandellP](https://github.com/RandellP))

### Fixed

- \(bug\) Use ARGV instead of ARGF [\#51](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/51) ([tkishel](https://github.com/tkishel))
- Allow for handling multiple hashes with STDIN [\#45](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/45) ([jarretlavallee](https://github.com/jarretlavallee))
- \(SLV-767\) Updated measurement tagging [\#43](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/43) ([RandellP](https://github.com/RandellP))
- \(SLV-771\) Fix bug where process data is missed [\#42](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/42) ([RandellP](https://github.com/RandellP))
- \(bug\) use full path to puppet in puma\_metrics [\#38](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/38) ([tkishel](https://github.com/tkishel))

## [5.3.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/5.3.0) (2019-12-11)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/5.2.0...5.3.0)

### Added

- \(SLV-688\) send script errors to the output file [\#32](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/32) ([RandellP](https://github.com/RandellP))
- \(SLV-672\) Add system class to manage system metric [\#30](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/30) ([RandellP](https://github.com/RandellP))
- Allow for excluding data from the metrics files [\#29](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/29) ([jarretlavallee](https://github.com/jarretlavallee))
- \(SLV-653\) Add a script for generating system stats [\#28](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/28) ([RandellP](https://github.com/RandellP))
- Skip versioncmp when pe\_server\_version is missing [\#23](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/23) ([Sharpie](https://github.com/Sharpie))

### Fixed

- Update the system metrics timestamp key [\#31](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/31) ([jarretlavallee](https://github.com/jarretlavallee))
- Change STDOUT.write to STDOUT.puts [\#27](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/27) ([m0dular](https://github.com/m0dular))
- Remove 127.0.0.1 special case naming [\#26](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/26) ([reidmv](https://github.com/reidmv))

## [5.2.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/5.2.0) (2019-09-09)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/5.1.2...5.2.0)

### Added

- \(PIE-51\) Ability to define a metrics server to ship to [\#19](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/19) ([HelenCampbell](https://github.com/HelenCampbell))

## [5.1.2](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/5.1.2) (2019-02-26)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/5.1.1...5.1.2)

## [5.1.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/5.1.1) (2019-01-25)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/5.1.0...5.1.1)

### Fixed

- Ensure tidy's tar captures large numbers of files [\#8](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/8) ([seanmil](https://github.com/seanmil))

## [5.1.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/5.1.0) (2018-12-17)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/2.7.0...5.1.0)

### Added

- Automate configuration of \_hosts parameters and clarify documentation [\#5](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/5) ([tkishel](https://github.com/tkishel))
- Sup-346 update to include puppetserver metrics for versions \< 2018.1.0 [\#3](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/pull/3) ([daniel5119](https://github.com/daniel5119))

## [2.7.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/2.7.0) (2018-04-13)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/1.9.0...2.7.0)

## [1.9.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/1.9.0) (2018-04-13)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/5.0.1...1.9.0)

## [5.0.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/5.0.1) (2018-04-06)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/5.0.0...5.0.1)

## [5.0.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/5.0.0) (2018-04-05)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.6.0...5.0.0)

## [4.6.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.6.0) (2017-11-13)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.5.0...4.6.0)

## [4.5.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.5.0) (2017-10-19)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.4.2...4.5.0)

## [4.4.2](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.4.2) (2017-10-19)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.4.1...4.4.2)

## [4.4.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.4.1) (2017-06-13)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.4.0...4.4.1)

## [4.4.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.4.0) (2017-06-13)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.3.0...4.4.0)

## [4.3.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.3.0) (2017-06-08)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.2.2...4.3.0)

## [4.2.2](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.2.2) (2017-06-08)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.2.1...4.2.2)

## [4.2.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.2.1) (2017-05-23)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.2.0...4.2.1)

## [4.2.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.2.0) (2017-04-28)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.1.0...4.2.0)

## [4.1.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.1.0) (2017-04-17)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/4.0.0...4.1.0)

## [4.0.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/4.0.0) (2017-04-07)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/3.0.1...4.0.0)

## [3.0.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/3.0.1) (2017-04-06)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/3.0.0...3.0.1)

## [3.0.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/3.0.0) (2017-04-04)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/2.0.0...3.0.0)

## [2.0.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/2.0.0) (2017-01-13)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/1.1.1...2.0.0)

## [1.1.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/1.1.1) (2016-12-05)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/1.1.0...1.1.1)

## [1.1.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/1.1.0) (2016-12-02)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/1.0.4...1.1.0)

## [1.0.4](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/1.0.4) (2016-11-18)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/2016.5.0...1.0.4)

## [2016.5.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/2016.5.0) (2016-11-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/1.0.3...2016.5.0)

## [1.0.3](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/1.0.3) (2016-11-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/2016.4.1...1.0.3)

## [2016.4.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/2016.4.1) (2016-10-12)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/1.0.2...2016.4.1)

## [1.0.2](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/1.0.2) (2016-09-07)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/1.0.1...1.0.2)

## [1.0.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/1.0.1) (2016-09-07)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/1.0.0) (2016-08-22)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/2016.4.0...1.0.0)

## [2016.4.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/2016.4.0) (2016-08-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/2016.3.0-rc0...2016.4.0)

## [2016.3.0-rc0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/2016.3.0-rc0) (2016-08-12)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/2016.2.1...2016.3.0-rc0)

## [2016.2.1](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/2016.2.1) (2016-06-15)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/2016.2.0...2016.2.1)

## [2016.2.0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/2016.2.0) (2016-06-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/2016.2.0-rc0...2016.2.0)

## [2016.2.0-rc0](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/tree/2016.2.0-rc0) (2016-04-20)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/compare/228fd72cea2c8547c4f038bd24c6b5fa33bba7f6...2016.2.0-rc0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
