require 'spec_helper'

describe 'puppet_metrics_collector' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end

  context 'when puppet_metrics_collector::system is included first' do
    let(:pre_condition) { 'include puppet_metrics_collector::system' }

    it { is_expected.to compile }
  end

  context 'when puppet_metrics_collector::system is included last' do
    let(:post_condition) { 'include puppet_metrics_collector::system' }

    it { is_expected.to compile }
  end
end
