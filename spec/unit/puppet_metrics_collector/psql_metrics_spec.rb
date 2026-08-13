require 'spec_helper'

# `load`, not `require`: the script has no .rb extension, so require can't
# find it. The script's own __FILE__ == $PROGRAM_NAME guard keeps this from
# running the CLI. Guarded so re-requiring this spec file doesn't redefine
# the class (and its Exec::Result Struct) a second time.
load File.expand_path('../../../files/psql_metrics', __dir__) unless defined?(PuppetMetricsCollector::PSQLMetrics)

describe PuppetMetricsCollector::PSQLMetrics do
  def build_metrics(pg_version = nil)
    allow(File).to receive(:executable?).and_call_original
    allow(File).to receive(:executable?).with('/opt/puppetlabs/server/bin/psql').and_return(true)
    metrics = described_class.new
    metrics.instance_variable_set(:@pg_version, Gem::Version.new(pg_version)) if pg_version
    metrics
  end

  def json_keys(sql)
    sql.scan(%r{'([a-z_]+)',}).flatten
  end

  describe '#checkpoints_query' do
    let(:expected_keys) do
      ['checkpoints_timed', 'checkpoints_req', 'checkpoint_write_time', 'checkpoint_sync_time',
       'buffers_checkpoint', 'buffers_clean', 'maxwritten_clean', 'buffers_backend',
       'buffers_backend_fsync', 'buffers_alloc', 'stats_reset']
    end

    it 'sources checkpoint counters from pg_stat_checkpointer on PG 17+' do
      query = build_metrics('17.10').checkpoints_query
      expect(query).to include('pg_stat_checkpointer')
      expect(query).to include('checkpointer.num_timed')
    end

    it 'reports buffers_backend and buffers_backend_fsync as NULL on PG 17+' do
      query = build_metrics('17.10').checkpoints_query
      expect(query).to match(%r{'buffers_backend',\s*NULL})
      expect(query).to match(%r{'buffers_backend_fsync',\s*NULL})
    end

    it 'keeps the unmodified pg_stat_bgwriter query on PG < 17' do
      query = build_metrics('16.4').checkpoints_query
      expect(query).not_to include('pg_stat_checkpointer')
      expect(query).to match(%r{'buffers_backend',\s*buffers_backend\b})
      expect(query).to match(%r{'buffers_backend_fsync',\s*buffers_backend_fsync\b})
    end

    it 'falls back to the pre-17 query when the version could not be determined' do
      query = build_metrics.checkpoints_query
      expect(query).not_to include('pg_stat_checkpointer')
    end

    it 'builds the same JSON key set regardless of PG version' do
      keys_pre17 = json_keys(build_metrics('16.4').checkpoints_query)
      keys_post17 = json_keys(build_metrics('17.10').checkpoints_query)

      expect(keys_pre17).to match_array(expected_keys)
      expect(keys_post17).to match_array(expected_keys)
    end
  end

  describe '#parse_pg_version' do
    let(:metrics) { build_metrics }

    {
      '17.10' => '17.10',
      '9.6.24' => '9.6.24',
      '17.10 (Debian 17.10-1.pgdg13+1)' => '17.10',
      '18beta1' => '18',
    }.each do |raw, expected|
      it "parses #{raw.inspect} as #{expected}" do
        expect(metrics.parse_pg_version(raw)).to eq(Gem::Version.new(expected))
      end
    end

    it 'records an error and returns nil for an unparseable version' do
      version = metrics.parse_pg_version('garbage')

      expect(metrics.instance_variable_get(:@errors).join).to include('Unable to parse Postgres version "garbage"')
      expect(version).to be_nil
    end
  end

  describe '#to_h' do
    let(:metrics) { build_metrics }

    it 'records an error without raising when the version cannot be parsed, and still collects other metrics' do
      # sql_query normally parses its result as JSON before returning it, so
      # this stub returns already-parsed Ruby values (matching what callers
      # actually receive), not raw JSON text.
      allow(metrics).to receive(:sql_query) do |query, **_opts|
        if query.include?('SHOW server_version')
          'not-a-version'
        elsif query.include?('max_connections')
          { 'active' => 1, 'max' => 400 }
        end
      end

      result = metrics.to_h
      expect(result[:error].join).to include('Unable to parse Postgres version')
      expect(result[:connections]).to eq('active' => 1, 'max' => 400)
    end

    it 'records other metrics without raising when the version query itself fails' do
      allow(metrics).to receive(:sql_query) do |query, **_opts|
        if query.include?('SHOW server_version')
          nil
        elsif query.include?('max_connections')
          { 'active' => 1, 'max' => 400 }
        end
      end

      result = metrics.to_h
      expect(result[:connections]).to eq('active' => 1, 'max' => 400)
    end
  end
end
