require 'spec_helper_acceptance'

describe 'hosts_with_pe_profile function' do
  it 'returns 127.0.0.1' do
    pp = <<-MANIFEST
       $result=puppet_metrics_collector::hosts_with_pe_profile('non_existant')
       notice "Received=$result"
       MANIFEST
    output = apply_manifest(pp).stdout
    expect(output).to match(%r{127.0.0.1})
  end
end
