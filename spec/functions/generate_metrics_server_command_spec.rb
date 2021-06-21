require 'spec_helper'

describe 'puppet_metrics_collector::generate_metrics_server_command' do
  context 'when the metrics parameters are undef' do
    it { is_expected.to run.with_params('scripts_dir').and_return('') }
  end

  context 'when the metrics type is influxdb' do
    context 'without the port' do
      it {
        is_expected.to run.with_params(
          'scripts_dir',
          'influxdb',
          'metrics_server_hostname',
          'metrics_server_db_name',
        ).and_return(
          '--print | scripts_dir/json2timeseriesdb --netcat metrics_server_hostname --convert-to influxdb --influx-db metrics_server_db_name -',
        )
      }
    end

    context 'with the port' do
      it {
        is_expected.to run.with_params(
          'scripts_dir',
          'influxdb',
          'metrics_server_hostname',
          'metrics_server_db_name',
          8080,
        ).and_return(
          '--print | scripts_dir/json2timeseriesdb --netcat metrics_server_hostname --convert-to influxdb --influx-db metrics_server_db_name --port 8080 -',
        )
      }
    end

    context 'without the database name' do
      it { is_expected.to run.with_params('scripts_dir', 'influxdb').and_raise_error(Puppet::ParseError) }
    end
  end

  context 'when metrics type is graphite' do
    it {
      is_expected.to run.with_params('scripts_dir', 'graphite',
'metrics_server_hostname').and_return('--print | scripts_dir/json2timeseriesdb --netcat metrics_server_hostname --convert-to graphite -')
    }
  end

  context 'when metrics type is splunk_hec' do
    it { is_expected.to run.with_params('scripts_dir', 'splunk_hec').and_return('--print | /opt/puppetlabs/bin/puppet splunk_hec --sourcetype puppet:metrics --pe_metrics') }
  end
end
