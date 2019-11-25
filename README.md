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
  * [Using with PE 3.8](#using-with-pe-38)

## Overview

This module collects metrics provided by the status endpoints of Puppet Enterprise services. The metrics can be used to identify performance issues that may be addressed by performance tuning.


## Setup


### Installation

Install this module with `puppet module install puppetlabs-puppet_metrics_collector` or add it to your Puppetfile.

To activate this module, classify your Primary Master (aka Master of Masters or MoM) with the `puppet_metrics_collector` class using your preferred classification method.

```
node 'master.example.com' {
  include puppet_metrics_collector
}
```

Optionally, you can also gather some basic system metrics.  Unlike the service metrics, this has to be enabled on each host you want metrics from, and the resulting data will be only on that host.  Do not include the top level puppet_metrics_collector on anything other than the master as it will collect the same data as the one on the master.  This functionality depends on sysstat.

```
node 'master.example.com' {
  include puppet_metrics_collector
  include puppet_metrics_collector::system
}

node 'compilerA.example.com', 'compilerB.example.com,' {
  include puppet_metrics_collector::system
}
``` 

### Configuration

This module automatically configures the hosts it queries by querying PuppetDB for PE Infrastructure Hosts. If there is an error with automatic configuration of hosts, refer to [Manual Configuration of Hosts](#manual-configuration-of-hosts).

#### Parameters

For each Puppet Enterprise service (Puppetserver, PuppetDB, Orchestration, and ActiveMQ) there are associated `<service_name>_hosts`, `<service_name>_ensure` and `<service_name>_port` parameters. Refer to `manifests/init.pp` for details.

##### output_dir

String: Output directory for collected metrics. Defaults to `/opt/puppetlabs/puppet-metrics-collector`.

##### collection_frequency

Integer: How often to collect metrics, in minutes. Defaults to `5`.

##### retention_days

Integer: How long to retain collect metrics, in days. Defaults to `90`.

##### Metrics Server Parameters

The following set of parameters begining with `metrics_server_` allows for the specification of a server type to use to generate and in some cases send data to a specified server.
Currently both `influxdb` and `graphite` types allow for the transfer of data while `splunk_hec` only generates the data.

##### metrics_server_type

Optional Enum['influxdb','graphite','splunk_hec']: specifies the metrics server type to write data to. Currently it supports `influxdb`, `graphite` and `splunk_hec` type servers.

To Note:

Please note that for `influxdb` server types a `dbname` must be provided.

Please note that for a server type of `splunk_hec` no data can be sent to a server with the current configuration, however the command will format the json output using the `splunk_hec` module, which is a requirement for this option and can be found on the Forge [here](https://forge.puppet.com/puppetlabs/splunk_hec) or [here](https://github.com/puppetlabs/puppetlabs-splunk_hec) on github.
Further setup instructions for using the `splunk_hec` module can be found within the modules own README.md.

##### metrics_server_hostname

Optional String: Allows you to define the host name of a server to send data to. Defaults to undef.

##### metrics_server_port

Optional Integer: Allows you to define the port number of a server to send data to. Defaults to undef.

##### metrics_server_db_name

Optional String: Allows you to define the database name of a server to send data to. Required for `metrics_server_type` of `influxdb`. Defaults to undef.

##### override_metrics_command

Optional String: Allows you to override the command that is run to gather metrics. Defaults to undef.


## Usage


### Grepping Metrics

You can search for useful information by performing a `grep` in the following format, run from inside the directory containing the metrics.

```
cd /opt/puppetlabs/puppet-metrics-collector
grep <metric_name> <service_name>/127.0.0.1/*.json
```

Since the metrics are compressed every night, you can only search metrics for the current day. To search older metrics, decompress the compressed files into a subdirectory of `/tmp` and run from inside that directory.


#### Grepping Puppetserver Metrics

Example:

```
grep average-free-jrubies puppetserver/127.0.0.1/*.json
puppetserver/127.0.0.1/20170404T170501Z.json:                "average-free-jrubies": 0.9950009285369501,
puppetserver/127.0.0.1/20170404T171001Z.json:                "average-free-jrubies": 0.9999444653324225,
puppetserver/127.0.0.1/20170404T171502Z.json:                "average-free-jrubies": 0.9999993830655706,
```

#### Grepping PuppetDB Metrics

Example:

```
grep queue_depth puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170404T170501Z.json:            "queue_depth": 0,
puppetdb/127.0.0.1/20170404T171001Z.json:            "queue_depth": 0,
puppetdb/127.0.0.1/20170404T171502Z.json:            "queue_depth": 0,
```

Example for PE 2016.5 and older:

```
grep Cursor puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170404T171001Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170404T171001Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170404T171001Z.json:          "CursorPercentUsage": 0,
puppetdb/127.0.0.1/20170404T171502Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170404T171502Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170404T171502Z.json:          "CursorPercentUsage": 0,
puppetdb/127.0.0.1/20170404T172002Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170404T172002Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170404T172002Z.json:          "CursorPercentUsage": 0,
```


### Sharing Metrics Data

When working with Support, you may be asked to provide an archive of collected metrics data.

This module provides a utility script, `puppet-metrics-collector` to prepare metrics data for sharing.

```
/opt/puppetlabs/bin/puppet-metrics-collector create-tarball
```

This script creates a tar archive in the current working directory.

```
[root@master ~]# /opt/puppetlabs/bin/puppet-metrics-collector create-tarball
Metrics data tarball created at: /root/puppet-metrics-20170801T180338Z.tar.gz
```

## Reference


### Directory Layout

This module creates an output directory with one subdirectory for each Puppet Enterprise service (Puppetserver, PuppetDB, Orchestration, and ActiveMQ) that this module has been configured to collect. Each service directory has one subdirectory for each host. Each host directory contains one JSON file, collected every 5 minutes. Once per day, the metrics for each service are compressed and saved in the root of its directory.

Example:

```
/opt/puppetlabs/puppet-metrics-collector/puppetserver
├── 127.0.0.1
│   ├── 20170404T020001Z.json
│   ├── ...
│   ├── 20170404T170501Z.json
│   └── 20170404T171001Z.json
└── puppetserver-2017.04.04.02.00.01.tar.bz2
/opt/puppetlabs/puppet-metrics-collector/puppetdb
└── 127.0.0.1
│   ├── 20170404T020001Z.json
│   ├── ...
│   ├── 20170404T170501Z.json
│   ├── 20170404T171001Z.json
└── puppetdb-2017.04.04.02.00.01.tar.bz2
```

### Cron Jobs

This module creates two cron jobs for each Puppet Enterprise service:

- A cron job to collect the metrics
  - Runs as per `collection_frequency`
- A cron job to compress collected metrics and delete metrics older than the retention period as per `retention_days`
  - Runs at randomly selected time between 12:00 AM and 3:00 AM

Example:

```
crontab -l
...
# Puppet Name: puppetserver_metrics_collection
*/5 * * * * /opt/puppetlabs/puppet-metrics-collector/scripts/puppetserver_metrics
# Puppet Name: puppetserver_metrics_tidy
0 2 * * * /opt/puppetlabs/puppet-metrics-collector/scripts/puppetserver_metrics_tidy
```


## Alternate Setup


### Temporary Installation

While a permanent installation is recommended, this module can be temporarily installed with the following commands.

```
puppet module install puppetlabs-puppet_metrics_collector --modulepath /tmp;
puppet apply -e "class { 'puppet_metrics_collector': }" --modulepath /tmp;
```


### Manual Configuration of Hosts

If necessary, you can manually configure this module by specifying parameters via the class declaration or via Hiera data. The preferred method is via Hiera data. The following examples show you how to specify those parameters for different infrastructures, and assumes you declare this module on the Primary Master.


#### Monolithic Infrastructure with Compile Masters

##### Hiera Data Example

```
puppet_metrics_collector::puppetserver_hosts:
 - 'master.example.com'
 - 'compile-master-1.example.com'
 - 'compile-master-2.example.com'
puppet_metrics_collector::puppetdb_hosts:
 - 'master.example.com'
```

##### Class Declaration Example

```
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

```
puppet_metrics_collector::puppetserver_hosts:
 - 'split-master.example.com'
puppet_metrics_collector::puppetdb_hosts:
 - 'split-puppetdb.example.com'
```

##### Class Declaration Example

```
class { 'puppet_metrics_collector':
  puppetserver_hosts => ['split-master.example.com'],
  puppetdb_hosts     => ['split-puppetdb.example.com'],
}
```


#### Split Infrastructure with Compile Masters

##### Hiera Data Example

```
puppet_metrics_collector::puppetserver_hosts:
 - 'split-master.example.com'
 - 'compile-master-1.example.com'
 - 'compile-master-2.example.com'
 puppet_metrics_collector::puppetdb_hosts:
  - 'split-puppetdb.example.com'
```

##### Class Definition Example

```
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

This option collect metrics on each PE Infrastructure Host instead of collecting metrics centrally on the MoM. This option is discouraged, but allows for the collection of metrics when the MoM cannot access the API endpoints of the other PE Infrastructure Hosts. Classify each PE Infrastructure Host with this module, specifying the following parameters.

* When classifying a Compile Master Host, specify `puppetdb_metrics_ensure => absent`
* When classifying a PuppetDB Host, specify `puppetserver_metrics_ensure => absent`


### Using with PE 3.8

You can use this module with PE 3.8, although it requires the [future parser](https://docs.puppet.com/puppet/3.8/experiments_future.html).

If the future parser is enabled, globally or in the environment, the following can be declared in site.pp.

```
class { 'puppet_metrics_collector':
  output_dir => '/opt/puppet/puppet_metrics_collector'
}
```

Otherwise, use the following commands.

```
puppet module install puppetlabs-puppet_metrics_collector --modulepath /tmp;
puppet apply -e "class { 'puppet_metrics_collector' : output_dir => '/opt/puppet/puppet_metrics_collector' }"  --modulepath /tmp --parser=future
```
