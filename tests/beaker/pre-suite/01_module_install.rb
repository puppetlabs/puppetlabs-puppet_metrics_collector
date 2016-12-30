require 'beaker/host_prebuilt_steps'

test_name 'PE-15434 - - Install pe_support_script Module' do
  extend Beaker::HostPrebuiltSteps

  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))
  puppet_module_dir = '/opt/puppetlabs/puppet/modules'
  meep_module_dir = '/opt/puppetlabs/server/data/enterprise/modules'
  controllers = hosts.reject {|h| not_controller(h) }

  step 'Re-install module from project source' do
    copy_module_to(controllers + hosts_as('compile_master'),
      module_name: 'pe_support_script',
      source: proj_root,
      target_module_path: puppet_module_dir)

    # Stub out the checksum file to prevent `puppet module changes` from
    # throwing an error.
    copy_file_to_remote(controllers + hosts_as('compile_master'),
      [puppet_module_dir, 'pe_support_script', 'checksums.json'].join('/'),
      '{}')

    copy_module_to(controllers,
      module_name: 'pe_support_script',
      source: proj_root,
      target_module_path: meep_module_dir)
  end

  step 'Distribute module to agents via pluginsync' do
    on(agents, puppet("plugin download"))
  end
end
