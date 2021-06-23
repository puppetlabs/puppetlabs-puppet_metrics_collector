require 'spec_helper_acceptance'

describe 'hosts_with_pe_profile function' do
  it 'returns 127.0.0.1 when no hosts are found' do
    pp = <<-MANIFEST
       $result=puppet_metrics_collector::hosts_with_pe_profile('non_existant')
       notice "Received=$result"
       MANIFEST
    output = apply_manifest(pp).stdout
    expect(output).to match(%r{Received=\[127.0.0.1\]})
  end
  it 'return the FQDN for the master profile' do
    # This influences the custom facts
    run_shell('puppet config set storeconfigs true --section user', expect_failures: false)
    pp = <<-MANIFEST
       $result=puppet_metrics_collector::hosts_with_pe_profile('master')
       notice "Received=$result"
       MANIFEST
    output = apply_manifest(pp).stdout
    expect(output).to match(%r{Received=\[#{host_inventory['fqdn']}\]})
    run_shell('puppet config set storeconfigs false --section user', expect_failures: false)
  end
end
