Table of Contents
=================

- [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Setup](#setup)
    - [Installation](#installation)
    - [Configuration](#configuration)
      - [Parameters](#parameters)
        - [output_dir](#output_dir)
        - [collection_frequency](#collection_frequency)
        - [retention_days](#retention_days)
        - [Metrics Server Parameters](#metrics-server-parameters)
        - [metrics_server_type](#metrics_server_type)
        - [metrics_server_hostname](#metrics_server_hostname)
        - [metrics_server_port](#metrics_server_port)
        - [metrics_server_db_name](#metrics_server_db_name)
        - [override_metrics_command](#override_metrics_command)
  - [Usage](#usage)
    - [Searching Metrics](#searching-metrics)
      - [Searching Puppetserver Metrics](#searching-puppetserver-metrics)
      - [Searching PuppetDB Metrics](#searching-puppetdb-metrics)
    - [Sharing Metrics Data](#sharing-metrics-data)
  - [Reference](#reference)
    - [Directory Layout](#directory-layout)
    - [Systemd Timers](#systemd-timers)
  - [Alternate Setup](#alternate-setup)
    - [Temporary Installation](#temporary-installation)
    - [Manual Configuration of Hosts](#manual-configuration-of-hosts)
      - [Monolithic Infrastructure with Compilers](#monolithic-infrastructure-with-compilers)
        - [Hiera Data Example](#hiera-data-example)
        - [Class Declaration Example](#class-declaration-example)
    - [Configuration for Distributed Metrics Collection](#configuration-for-distributed-metrics-collection)
  - [How to Report an issue or contribute to the module](#how-to-report-an-issue-or-contribute-to-the-module)
- [Supporting Content](#supporting-content)
    - [Articles](#articles)
    - [Videos](#videos)

## Overview

This module collects metrics provided by the status endpoints of Puppet Enterprise services.
The metrics can be used to identify performance issues that may be addressed by performance tuning.


> For PE versions older than 2019.8.5, access to the `/metrics/v2` API endpoint is restricted to `localhost` as a mitigation for [CVE-2020-7943](https://puppet.com/security/cve/CVE-2020-7943/). This module requires access the `/metrics/v2` API to collect a complete set of performance metrics from PuppetDB. Refer to [Configuration for Distributed Metrics Collection](#Configuration-for-distributed-metrics-collection) for a workaround.


## Setup


### Installation

Install this module with `puppet module install puppetlabs-puppet_metrics_collector` or add it to your Puppetfile.

To activate this module, classify your Primary Server with the `puppet_metrics_collector` class using your preferred classification method.
Below is an example using `site.pp`.

```puppet
node 'primary.example.com' {
  include puppet_metrics_collector
}
```

Optionally, you can gather basic system metrics.
Unlike service metrics, system metrics have to be enabled locally on each PE Infrastructure Host, and the resulting data will be stored locally on that host.
This functionality depends on `sysstat`.

```puppet
node 'primary.example.com' {
  include puppet_metrics_collector
  include puppet_metrics_collector::system
}

node 'compilerA.example.com', 'compilerB.example.com,' {
  include puppet_metrics_collector::system
}
```

> Note: Do not `include` the top-level `puppet_metrics_collector` class on any PE Infrastructure Host other than the Primary Server, otherwise it will collect the same data as the Primary Server.

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


### Searching Metrics

Metrics are formatted as a JSON hash on one line.
In order to convert the metric files into a multi-line format, they can be processed with `python -m json.tool` as per below.

```bash
cd /opt/puppetlabs/puppet-metrics-collector
for i in <service_name>/primary.example.com/*.json; do echo "$(python -m json.tool < $i)" > $i; done
```

You can search for useful information by performing a `grep`, run from inside the directory containing the metrics

```bash
cd /opt/puppetlabs/puppet-metrics-collector
grep -oP '"<metric_name>,*?,' <service_name>/primary.example.com/*.json
```

or JQ if available
```bash
cd /opt/puppetlabs/puppet-metrics-collector
jq '.. |."<metric_name>"? | select(. != null)| input_filename , .' -- <service_name>/primary.example.com/*.json
```

Since the metrics are archived once per day, you can only search metrics for the current day.
To search older metrics, decompress the archived files into a subdirectory of `/tmp` and run your search from inside that directory.

#### Searching Puppetserver Metrics

Example:

```bash
grep -oP '"average-free-jrubies.*?,' puppetserver/primary.example.com/*.json

puppetserver/primary.example.com/20190404T170501Z.json:"average-free-jrubies":0.9950009285369501,
puppetserver/primary.example.com/20190404T171001Z.json:"average-free-jrubies":0.9999444653324225,
puppetserver/primary.example.com/20190404T171502Z.json:"average-free-jrubies":0.9999993830655706,
```

```bash
jq '.. |."average-free-jrubies"? | select(. != null)| input_filename , .' -- puppetserver/primary.example.com/*.json

"puppetserver/primary.example.com/20190404T170501Z.json"
0.9950009285369501
"puppetserver/primary.example.com/20190404T171001Z.json"
0.9999444653324225,
"puppetserver/primary.example.com/20190404T171502Z.json"
0.9999993830655706,
```

#### Searching PuppetDB Metrics

Example:

```bash
grep -oP '"queue_depth.*?,' puppetdb/primary.example.com/*.json

puppetdb/primary.example.com/20190404T170501Z.json: "queue_depth": 0,
puppetdb/primary.example.com/20190404T171001Z.json: "queue_depth": 0,
puppetdb/primary.example.com/20190404T171502Z.json: "queue_depth": 0,
```

```bash
jq '.. |."queue_depth "? | select(. != null)| input_filename , .' -- puppetdb/primary.example.com/*.json

"puppetdb/primary.example.com/20190404T170501Z.json"
0
"puppetdb/primary.example.com/20190404T171001Z.json"
0
"puppetdb/primary.example.com/20190404T171502Z.json" 
0
```

### Sharing Metrics Data

When working with Support, you may be asked for an archive of collected metrics data.

This module provides a script, `create-metrics-archive` to archive metrics data for sending to Support.

```bash
/opt/puppetlabs/puppet-metrics-collector/scripts/create-metrics-archive
```

This script creates the archive in the current working directory.

It takes an optional `-m` or `--metrics-directory` parameter (default `/opt/puppetlabs/puppet-metrics-collector`) to specify an alterate metrics directory to archive.

It takes an optional `-r` or `--retention-days` parameter (default: `30`) to limit the number of days to include in the archive.

```bash
[root@primary ~]# /opt/puppetlabs/puppet-metrics-collector/scripts/create-metrics-archive
Created metrics archive: /root/puppet-metrics-collector-20200203T123456Z.tar.gz
```

## Reference


### Directory Layout

This module creates an output directory with one subdirectory for each Puppet Enterprise service (Puppet Server, PuppetDB, Orchestrator, Ace, Bolt, and ActiveMQ) that this module has been configured to collect.
Each service directory has one subdirectory for each host.
Each host directory contains one JSON file, collected every 5 minutes.
Once per day, the metrics for each service are archived and compressed.

Example:

```bash
/opt/puppetlabs/puppet-metrics-collector/puppetserver
├── primary.example.com
│   ├── 20190404T020001Z.json
│   ├── ...
│   ├── 20190404T170501Z.json
│   └── 20190404T171001Z.json
└── puppetserver-2019.04.04.02.00.01.tar.gz
/opt/puppetlabs/puppet-metrics-collector/puppetdb
└── primary.example.com
│   ├── 20190404T020001Z.json
│   ├── ...
│   ├── 20190404T170501Z.json
│   ├── 20190404T171001Z.json
└── puppetdb-2019.04.04.02.00.01.tar.gz
```

### Systemd Timers

This module creates two systemd timers for each Puppet Enterprise service:

- One to collect the metrics
  - Runs as per `collection_frequency`
- One to archive collected metrics and delete metrics older than the retention period, as per `retention_days`
  - Runs at randomly selected time between 12:00 AM and 3:00 AM

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
The following examples show you how to specify those parameters for different infrastructures, and assumes you declare this module on the Primary Server.


#### Monolithic Infrastructure with Compilers

##### Hiera Data Example

```yaml
puppet_metrics_collector::puppetserver_hosts:
 - 'primary.example.com'
 - 'compiler-1.example.com'
 - 'compiler-2.example.com'
puppet_metrics_collector::puppetdb_hosts:
 - 'primary.example.com'
```

##### Class Declaration Example

```puppet
class { 'puppet_metrics_collector':
  puppetserver_hosts => [
    'primary.example.com',
    'compiler-1.example.com',
    'compiler-2.example.com'
  ],
  puppetdb_hosts     => ['primary.example.com'],
}
```


### Configuration for Distributed Metrics Collection

This option collect metrics on each PE Infrastructure Host instead of collecting metrics centrally on the Primary Server.
This option is discouraged, but allows for the collection of metrics when the Primary Server cannot access the API endpoints of the other PE Infrastructure Hosts.
Classify each PE Infrastructure Host with this module, specifying the following parameters.

When classifying a Compiler, specify these additional parameters:

```puppet
class { 'puppet_metrics_collector':
  puppetserver_hosts          => ['127.0.0.1'],
  puppetdb_metrics_ensure     => absent,
  orchestrator_metrics_ensure => absent,
  ace_metrics_ensure          => absent,
  bolt_metrics_ensure         => absent,
}
```

When classifying a PuppetDB Host, specify these additional parameters:

```puppet
class { 'puppet_metrics_collector':
  puppetdb_hosts              => ['127.0.0.1'],
  puppetserver_metrics_ensure => absent,
  orchestrator_metrics_ensure => absent,
  ace_metrics_ensure          => absent,
  bolt_metrics_ensure         => absent,
}
```


## How to Report an issue or contribute to the module

If you are a PE user and need support using this module or are encountering issues, our Support team would be happy to help you resolve your issue and help reproduce any bugs. Just raise a ticket on the [support portal](https://support.puppet.com/hc/en-us/requests/new).
 If you have a reproducible bug or are a community user you can raise it directly on the Github issues page of the module [here](https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/issues). We also welcome PR contributions to improve the module. Please see further details about contributing [here](https://puppet.com/docs/puppet/7.5/contributing.html#contributing_changes_to_module_repositories).


---

# Supporting Content

### Articles

The [Support Knowledge base](https://support.puppet.com/hc/en-us) is a searchable repository for technical information and how-to guides for all Puppet products.

This Module has the following specific Article(s) available:

1. [Troubleshoot and fix performance issues with the puppetlabs-puppet_metrics_collector module in Puppet Enterprise ](https://support.puppet.com/hc/en-us/articles/231751308)
2. [Manage the installation and configuration of metrics dashboards using the puppetlabs-puppet_metrics_dashboard module for Puppet Enterprise 2016.4 to 2019.1](https://support.puppet.com/hc/en-us/articles/360006641414)
3. [Troubleshooting potential issues in Puppet Enterprise: How to learn more](https://support.puppet.com/hc/en-us/articles/360004106074)

### Videos

The [Support Video Playlist](https://youtube.com/playlist?list=PLV86BgbREluWKzzvVulR74HZzMl6SCh3S) is a resource of content generated by the support team

This Module has the following specific video content  available:


1. [Puppet Metrics Overview ](https://youtu.be/LiCDoOUS4hg)
2. [Collecting and Displaying Puppet Metrics](https://youtu.be/13sBMQGDqsA)
3. [Interpreting Puppet Metrics](https://youtu.be/09iDO3DlKMQ)

   
   ---

