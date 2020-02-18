#!/opt/puppetlabs/puppet/bin/ruby

require 'net/https'
require 'json'
require 'uri'
require 'time'
require 'optparse'
require 'yaml'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"
  opts.on('-p', '--[no-]print', 'Print to STDOUT') { |p| options[:print] = p }
  opts.on('-m [TYPE]', '--metrics_type [TYPE]', 'Type of metrics to collect') { |v| options[:metrics_type] = v }
  opts.on('-o [DIR]', '--output_dir [DIR]', 'Directory to save output to') { |o| options[:output_dir] = o }
  opts.on('--metrics_port [PORT]', 'The port the metrics service runs on') { |port| options[:metrics_port] = port }
  opts.on('--[no-]ssl', 'Use SSL when collecting metrics') { |ssl| options[:ssl] = ssl }
end.parse!

if options[:metrics_type].nil? then
  STDERR.puts '--metrics_type (-m) is a required argument'
  exit 1
end

# Allow scripts that require this script to access the options hash.
OPTIONS = options

config_file = File.expand_path("../../config/#{options[:metrics_type]}.yaml", __FILE__)
config = YAML.load_file(config_file)

def coalesce(higher_precedence, lower_precedence, default = nil)
  [higher_precedence, lower_precedence].find{|x|!x.nil?} || default
end

METRICS_TYPE       = options[:metrics_type]
OUTPUT_DIR         = options[:output_dir]
PE_VERSION         = config['pe_version']
CERTNAME           = config['clientcert']
HOSTS              = config['hosts']
PORT               = coalesce(options[:metrics_port], config['metrics_port'])
USE_SSL            = coalesce(options[:ssl], config['ssl'], true)
EXCLUDES           = config['excludes']
ADDITIONAL_METRICS = config['additional_metrics']

# Metrics endpoints for our Puma services require a client certificate with SSL.
# Metrics endpoints for our Trapper Keeper services do not require a client certificate.

if USE_CLIENTCERT
  SSLDIR = `/usr/local/bin/puppet config print ssldir`.chomp
end

$error_array = []

def generate_host_url(host, port, use_ssl)
  protocol = use_ssl ? 'https' : 'http'

  host_url = "#{protocol}://#{host}:#{port}"
end

def setup_connection(url, use_ssl)
  uri  = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)

  if use_ssl then
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    if USE_SSL && USE_CLIENTCERT
      # PE Puma services serve metrics from endpoints requiring a client certificate.
      # If https://github.com/puma/puma/pull/2098 is merged into the Puma used by PE,
      # we can collect metrics from /stats and /gc-stats without a client certificate.
      http.ca_path = "#{SSLDIR}/ca"
      http.ca_file = "#{SSLDIR}/certs/ca.pem"
      http.cert    = OpenSSL::X509::Certificate.new(File.read("#{SSLDIR}/certs/#{CERTNAME}.pem"))
      http.key     = OpenSSL::PKey::RSA.new(File.read("#{SSLDIR}/private_keys/#{CERTNAME}.pem"))
    end
  end

  return http, uri
end

def get_endpoint(url, use_ssl)
  http, uri = setup_connection(url, use_ssl)

  data = JSON.parse(http.get(uri.request_uri).body)
rescue Exception => e
    $error_array << "#{e}"
    data = {}
end

def post_endpoint(url, use_ssl, post_data)
  http, uri = setup_connection(url, use_ssl)

  request = Net::HTTP::Post.new(uri.request_uri)
  request.content_type = 'application/json'
  request.body = post_data

  data = JSON.parse(http.request(request).body)
rescue Exception => e
    $error_array << "#{e}"
    data = {}
end

def individually_retrieve_additional_metrics(host, port, use_ssl, metrics)
  host_url = generate_host_url(host, port, use_ssl)

  metrics_array = []
  metrics.each do |metric|
    endpoint = URI.escape("#{host_url}/metrics/v1/mbeans/#{metric['url']}")
    metrics_array <<  { 'name' => metric['name'], 'data' => get_endpoint(endpoint, use_ssl) }
  end

  return metrics_array
end

def bulk_retrieve_additional_metrics(host, port, use_ssl, metrics)
  host_url = generate_host_url(host, port, use_ssl)

  post_data = []
  metrics.each do |metric|
    post_data << metric['url']
  end

  endpoint = "#{host_url}/metrics/v1/mbeans"
  metrics_output = post_endpoint(endpoint, use_ssl, post_data.to_json)
  metrics_array = []

  metrics.each_index do |index|
    metric_name = metrics[index]['name']
    metric_data = metrics_output[index]
    metrics_array << { 'name' => metric_name, 'data' => metric_data }
  end

  return metrics_array
end

def retrieve_additional_metrics(host, port, use_ssl, pe_version, metrics)
  if Gem::Version.new(pe_version) < Gem::Version.new('2016.2.0') then
    metrics_array = individually_retrieve_additional_metrics(host, port, use_ssl, metrics)
  else
    metrics_array = bulk_retrieve_additional_metrics(host, port, use_ssl, metrics)
  end

  return metrics_array
end

def filter_metrics(dataset, filters)
  return dataset if filters.empty?

  case dataset
  when Hash
    dataset = dataset.inject({}) {|m, (k, v)| m[k] = filter_metrics(v,filters) unless filters.include? k ; m }
  when Array
    dataset.map! {|e| filter_metrics(e,filters)}
  end

  return dataset
end
