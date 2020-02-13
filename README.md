Table of Contents
=================

* [Overview](#overview)
* [Setup](#setup)
  * [Installation](#installation)
  * [Configuration](#configuration)
* [Usage](#usage)
  * [Grepping Metrics](#grepping-metrics)
  * [Sharing Metrics Data](#sharing-metrics-data)
* [Reference](#reference)
  * [Directory Layout](#directory-layout)
  * [Cron Jobs](#cron-jobs)
* [Alternate Setup](#alternate-setup)
  * [Temporary Installation](#temporary-installation)
  * [Manual Configuration of Hosts](#manual-configuration-of-hosts)
  * [Configuration for Distributed Metrics Collection](#Configuration-for-distributed-metrics-collection)

## Overview

This module collects metrics provided by the status endpoints of Puppet Enterprise services.
The metrics can be used to identify performance issues that may be addressed by performance tuning.


## Setup


### Installation

Install this module with `puppet module install puppetlabs-puppet_metrics_collector` or add it to your Puppetfile.

To activate this module, classify your Primary Master (aka Master of Masters or MoM) with the `puppet_metrics_collector` class using your preferred classification method.
Below is an example using `site.pp`.

```puppet
node 'master.example.com' {
  include puppet_metrics_collector
}
```

Optionally, you can gather basic system metrics.
Unlike service metrics, system metrics have to be enabled locally on each PE Infrastructure Host, and the resulting data will be stored locally on that host.
This functionality depends on `sysstat`.

```puppet
node 'master.example.com' {
  include puppet_metrics_collector
  include puppet_metrics_collector::system
}

node 'compilerA.example.com', 'compilerB.example.com,' {
  include puppet_metrics_collector::system
}
```

> Note: Do not `include` the top-level `puppet_metrics_collector` class on any PE Infrastructure Host other than the Primary Master, otherwise it will collect the same data as the Primary Master.

### Configuration

This module automatically configures the hosts it collects metrics from by querying PuppetDB for PE Infrastructure Hosts.
If there is an error with the automatic configuration of hosts, refer to [Manual Configuration of Hosts](#manual-configuration-of-hosts).

#### Parameters

For each Puppet Enterprise service (Puppet Server, PuppetDB, Orchestrator, Ace, Bolt, and ActiveMQ) there are associated `<service_name>_ensure`, `<service_name>_hosts`, and `<service_name>_port` parameters.
Refer to `manifests/init.pp` for details.

##### output_dir

`String`: Output directory for collected metrics.

Defaults to `/opt/puppetlabs/puppet-metrics-collector`.

##### collection_frequency

`Integer`: How often to collect metrics, in minutes.

Defaults to `5`.

##### retention_days

`Integer`: How long to retain collect metrics, in days.

Defaults to `90`.

##### Metrics Server Parameters

The following set of parameters begining with `metrics_server_` allows for the specification of a server type to use to generate and (in some cases) send data to a specified metrics server.
Currently, both `influxdb` and `graphite` types allow for the transfer of data while `splunk_hec` only generates data.

##### metrics_server_type

Optional `Enum['influxdb','graphite','splunk_hec']`: The metrics server type to send data to.

Currently, this module supports `influxdb`, `graphite`, and `splunk_hec` metrics server types.

For the `influxdb` metrics server type, a `metrics_server_db_name` must be provided.

For the `splunk_hec` metrics server type, data cannot be sent to a server, however the command will format the JSON output using the `splunk_hec` module, which is a requirement for this option. The `splunk_hec` module can be found on the [Forge](https://forge.puppet.com/puppetlabs/splunk_hec) or [GitHub](https://github.com/puppetlabs/puppetlabs-splunk_hec).
Setup instructions for the `splunk_hec` module can be found within that module's README.

##### metrics_server_hostname

Optional `String`: The hostname of the metrics server to send data to.

Defaults to `undef`.

##### metrics_server_port

Optional `Integer`: The port number of the metrics server to send data to.

Defaults to `undef`.

##### metrics_server_db_name

Optional `String`: The database name on the metrics server to send data to.

Required for `metrics_server_type` of `influxdb`.

Defaults to `undef`.

##### override_metrics_command

Optional `String`: Allows you to define the command that is executed to gather metrics.

Defaults to `undef`.


## Usage


### Grepping Metrics

Metrics are formatted as a JSON hash on one line.
In order to convert the metric files into a multi-line format, they can be processed with `python -m json.tool` as per below.

```bash
cd /opt/puppetlabs/puppet-metrics-collector
for i in <service_name>/master.example.com/*.json; do echo "$(python -m json.tool < $i)" > $i; done
```

You can search for useful information by performing a `grep`, run from inside the directory containing the metrics.

```bash
cd /opt/puppetlabs/puppet-metrics-collector
grep <metric_name> <service_name>/master.example.com/*.json
```

Since the metrics are compressed once per day, you can only search metrics for the current day.
To search older metrics, decompress the compressed files into a subdirectory of `/tmp` and run search from inside that directory.

#### Grepping Puppetserver Metrics

Example:

```bash
grep average-free-jrubies puppetserver/master.example.com/*.json

puppetserver/master.example.com/20190404T170501Z.json: "average-free-jrubies": 0.9950009285369501,
puppetserver/master.example.com/20190404T171001Z.json: "average-free-jrubies": 0.9999444653324225,
puppetserver/master.example.com/20190404T171502Z.json: "average-free-jrubies": 0.9999993830655706,
```

#### Grepping PuppetDB Metrics

Example:

```bash
grep queue_depth puppetdb/master.example.com/*.json

puppetdb/master.example.com/20190404T170501Z.json: "queue_depth": 0,
puppetdb/master.example.com/20190404T171001Z.json: "queue_depth": 0,
puppetdb/master.example.com/20190404T171502Z.json: "queue_depth": 0,
```

Example for PE 2016.5 and older:

```bash
grep Cursor puppetdb/master.example.com/*.json

puppetdb/master.example.com/20190404T171001Z.json: "CursorMemoryUsage": 0,
puppetdb/master.example.com/20190404T171001Z.json: "CursorFull": false,
puppetdb/master.example.com/20190404T171001Z.json: "CursorPercentUsage": 0,
puppetdb/master.example.com/20190404T171502Z.json: "CursorMemoryUsage": 0,
puppetdb/master.example.com/20190404T171502Z.json: "CursorFull": false,
puppetdb/master.example.com/20190404T171502Z.json: "CursorPercentUsage": 0,
puppetdb/master.example.com/20190404T172002Z.json: "CursorMemoryUsage": 0,
puppetdb/master.example.com/20190404T172002Z.json: "CursorFull": false,
puppetdb/master.example.com/20190404T172002Z.json: "CursorPercentUsage": 0,
```

### Sharing Metrics Data

When working with Support, you may be asked for an archive of collected metrics data.

This module provides a script, `create-metrics-archive` to prepare metrics data for sharing with Support.

```bash
/opt/puppetlabs/puppet-metrics-collector/scripts/create-metrics-archive
```

This script creates a tar archive in the current working directory.

```bash
[root@master ~]# /opt/puppetlabs/puppet-metrics-collector/scripts/create-metrics-archive
Created metrics archive file: /root/puppet-metrics-collector-20200203T123456Z.tar.gz
```

## Reference


### Directory Layout

This module creates an output directory with one subdirectory for each Puppet Enterprise service (Puppet Server, PuppetDB, Orchestrator, Ace, Bolt, and ActiveMQ) that this module has been configured to collect.
Each service directory has one subdirectory for each host.
Each host directory contains one JSON file, collected every 5 minutes.
Once per day, the metrics for each service are compressed.

Example:

```bash
/opt/puppetlabs/puppet-metrics-collector/puppetserver
├── master.example.com
│   ├── 20190404T020001Z.json
│   ├── ...
│   ├── 20190404T170501Z.json
│   └── 20190404T171001Z.json
└── puppetserver-2019.04.04.02.00.01.tar.bz2
/opt/puppetlabs/puppet-metrics-collector/puppetdb
└── master.example.com
│   ├── 20190404T020001Z.json
│   ├── ...
│   ├── 20190404T170501Z.json
│   ├── 20190404T171001Z.json
└── puppetdb-2019.04.04.02.00.01.tar.bz2
```

### Cron Jobs

This module creates two cron jobs for each Puppet Enterprise service:

- A cron job to collect the metrics
  - Runs as per `collection_frequency`
- A cron job to compress collected metrics and delete metrics older than the retention period as per `retention_days`
  - Runs at randomly selected time between 12:00 AM and 3:00 AM

Example:

```bash
crontab -l
...
# Puppet Name: puppetserver_metrics_collection
*/5 * * * * /opt/puppetlabs/puppet-metrics-collector/scripts/tk_metrics --metrics_type puppetserver --output_dir /opt/puppetlabs/puppet-metrics-collector/puppetserver
# Puppet Name: puppetserver_metrics_tidy
0 2 * * * /opt/puppetlabs/puppet-metrics-collector/scripts/metrics_tidy /opt/puppetlabs/puppet-metrics-collector puppetserver 90
```


## Alternate Setup


### Temporary Installation

While a permanent installation is recommended, this module can be temporarily installed with the following commands.

```bash
puppet module install puppetlabs-puppet_metrics_collector --modulepath /tmp;
puppet apply -e "class { 'puppet_metrics_collector': }" --modulepath /tmp;
```


### Manual Configuration of Hosts

If necessary, you can manually configure this module by specifying parameters via the class declaration or via Hiera data.
The preferred method is via Hiera data.
The following examples show you how to specify those parameters for different infrastructures, and assumes you declare this module on the Primary Master.


#### Monolithic Infrastructure with Compile Masters

##### Hiera Data Example

```yaml
puppet_metrics_collector::puppetserver_hosts:
 - 'master.example.com'
 - 'compile-master-1.example.com'
 - 'compile-master-2.example.com'
puppet_metrics_collector::puppetdb_hosts:
 - 'master.example.com'
```

##### Class Declaration Example

```puppet
class { 'puppet_metrics_collector':
  puppetserver_hosts => [
    'master.example.com',
    'compile-master-1.example.com',
    'compile-master-2.example.com'
  ],
  puppetdb_hosts     => ['master.example.com'],
}
```


#### Split Infrastructures without Compile Masters

##### Hiera Data Example

```yaml
puppet_metrics_collector::puppetserver_hosts:
 - 'split-master.example.com'
puppet_metrics_collector::puppetdb_hosts:
 - 'split-puppetdb.example.com'
```

##### Class Declaration Example

```puppet
class { 'puppet_metrics_collector':
  puppetserver_hosts => ['split-master.example.com'],
  puppetdb_hosts     => ['split-puppetdb.example.com'],
}
```


#### Split Infrastructure with Compile Masters

##### Hiera Data Example

```yaml
puppet_metrics_collector::puppetserver_hosts:
 - 'split-master.example.com'
 - 'compile-master-1.example.com'
 - 'compile-master-2.example.com'
 puppet_metrics_collector::puppetdb_hosts:
  - 'split-puppetdb.example.com'
```

##### Class Definition Example

```puppet
class { 'puppet_metrics_collector':
  puppetserver_hosts => [
    'split-master.example.com',
    'compile-master-1.example.com',
    'compile-master-2.example.com'
  ],
  puppetdb_hosts => ['split-puppetdb.example.com'],
}
```


### Configuration for Distributed Metrics Collection

This option collect metrics on each PE Infrastructure Host instead of collecting metrics centrally on the Primary Master.
This option is discouraged, but allows for the collection of metrics when the Primary Master cannot access the API endpoints of the other PE Infrastructure Hosts.
Classify each PE Infrastructure Host with this module, specifying the following parameters.

When classifying a Compile Master, specify these additional parameters:

```puppet
  puppetdb_metrics_ensure     => absent,
  orchestrator_metrics_ensure => absent,
  ace_metrics_ensure          => absent,
  bolt_metrics_ensure         => absent,
```

When classifying a PuppetDB Host, specify these additional parameters:

```puppet
  puppetserver_metrics_ensure => absent,
  orchestrator_metrics_ensure => absent,
  ace_metrics_ensure          => absent,
  bolt_metrics_ensure         => absent,
```
