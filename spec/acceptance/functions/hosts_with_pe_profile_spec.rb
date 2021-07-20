require 'spec_helper_acceptance'

describe 'hosts_with_pe_profile function' do
  it 'returns the certname of the node when no hosts are found' do
    pp = <<-MANIFEST
       $result=puppet_metrics_collector::hosts_with_pe_profile('non_existant')
       notice "Received=$result"
       MANIFEST
    output = apply_manifest(pp).stdout
    expect(output).to match(%r{Received=\[#{host_inventory['fqdn']}\]})
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

  it 'returns the certname of the node when storeconfigs is false' do
    # Should be set to false in the previous section
    # In this case, the certname == fqdn, so we use that here
    pp = <<-MANIFEST
       $result=puppet_metrics_collector::hosts_with_pe_profile('master')
       notice "Received=$result"
       MANIFEST
    output = apply_manifest(pp).stdout
    expect(output).to match(%r{Received=\[#{host_inventory['fqdn']}\]})
  end
end
