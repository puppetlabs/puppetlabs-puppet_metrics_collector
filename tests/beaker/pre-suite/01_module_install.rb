test_name 'PE-15434 - - Install pe_support_script Module' do
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))
  meep_module_dir = '/opt/puppetlabs/server/data/enterprise/modules'

  step 'Install pe_support_script Module' do
    # Ensure any module packaged with the installer is removed.
    on(hosts, "rm -rf #{meep_module_dir}/pe_support_script")

    install_dev_puppet_module(
      module_name: 'pe_support_script',
      source: proj_root,
      target_module_path: meep_module_dir,
    )
  end
end
