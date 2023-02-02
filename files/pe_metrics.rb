require 'json'
require 'uri'
require 'time'
require 'optparse'
require 'yaml'
require 'puppet'
require 'puppet/http'

module PuppetX
  module Puppetlabs
    # Mixin module to provide instance variables and methods to the tk_metris script
    module PuppetMetricsCollector
      attr_accessor :client, :metrics_type, :output_dir, :certname, :hosts, :port, :excludes, :additional_metrics, :print, :errors

      def metrics_collector_setup
        # The Puppet HTTP client takes care of connection pooling, client cert auth, and more for us
        @client ||= Puppet.runtime[:http]
        @errors ||= []

        OptionParser.new { |opts|
          opts.banner = "Usage: #{File.basename(__FILE__)} [options]"
          opts.on('-p', '--[no-]print', 'Print to STDOUT') { |p| @print = p }
          opts.on('-m [TYPE]', '--metrics_type [TYPE]', 'Type of metrics to collect') { |v| @metrics_type = v }
          opts.on('-o [DIR]', '--output_dir [DIR]', 'Directory to save output to') { |o| @output_dir = o }
          opts.on('--metrics_port [PORT]', 'The port the metrics service runs on') { |port| @metrics_port = port }
        }.parse!
        if @metrics_type.nil?
          STDERR.puts '--metrics_type (-m) is a required argument'
          exit 1
        end

        config_file = File.expand_path("../../config/#{@metrics_type}.yaml", __FILE__)
        config = YAML.load_file(config_file)

        @certname = config['certname']
        @hosts = config['hosts']
        @excludes = config['excludes']
        @additional_metrics = config['additional_metrics']
        @port = @metrics_port ? @metrics_port : config['metrics_port']
      rescue StandardError => e
        STDERR.puts "Failed to load config for #{@metrics_type}: #{e.message}"
        STDERR.puts e.backtrace
        nil
      end

      def get_endpoint(url)
        response = @client.get(url)

        if response.success?
          JSON.parse(response.body)
        else
          STDERR.puts "Received HTTP code '#{response.code}' with message '#{response.reason}' for #{url}"
          @errors << "HTTP Error #{response.code} for #{url}"
          {}
        end
      rescue StandardError => e
        STDERR.puts "Failed to query #{url}: #{e.message}"
        STDERR.puts e.backtrace

        @errors << e.to_s
        {}
      end

      def post_endpoint(url, body)
        response = @client.post(url, body, headers: { 'Content-Type' => 'application/json' })
        if response.success?
          JSON.parse(response.body)
        else
          STDERR.puts "Received HTTP code '#{response.code}' with message '#{response.reason}' for #{url}"
          @errors << "HTTP Error #{response.code} for #{url}"
          {}
        end
      rescue StandardError => e
        STDERR.puts "Failed to post to #{url}: #{e.message}"
        STDERR.puts e.backtrace

        @errors << e.to_s
        {}
      end

      def retrieve_additional_metrics(url, _metrics_type, metrics)
        metrics_output = post_endpoint(url, metrics.to_json)
        return [] if metrics_output.empty?

        # For a status other than 200 or 404, add the HTTP code to the error array
        metrics_output.select { |m| m.key?('status') and ![200, 404].include?(m['status']) }.each do |m|
          @errors << "HTTP Error #{m['status']} for #{m['request']['mbean']}"
        end

        # Select metrics output that has a 'status' key
        metrics_output.select { |m| m.key?('status') }.map do |m|
          # Then merge the corresponding 'metrics' hash
          # e.g. for a metrics_output entry of
          #   {"request"=>{"mbean"=>"puppetlabs.puppetdb.mq:name=global.command-parse-time", "type"=>"read"}, "value" => ...}
          # and a metrics entry of
          #   {"type"=>"read", "name"=>"global_command-parse-time", "mbean"=>"puppetlabs.puppetdb.mq:name=global.command-parse-time"}
          # the result is that 'name' entry is added to the metris_output hash
          m.merge!(metrics.find { |n| n['mbean'] == m['request']['mbean'] })

          status = m['status']
          if status == 200
            { 'name' => m['name'], 'data' => m['value'] }
          elsif status == 404
            { 'name' => m['name'], 'data' => nil }
          end
        end
      end

      def filter_metrics(dataset, filters)
        return dataset if filters.empty?

        case dataset
        when Hash
          dataset = dataset.each_with_object({}) { |(k, v), m| m[k] = filter_metrics(v, filters) unless filters.include? k; }
        when Array
          dataset.map! { |e| filter_metrics(e, filters) }
        end

        dataset
      end
    end
  end
end
