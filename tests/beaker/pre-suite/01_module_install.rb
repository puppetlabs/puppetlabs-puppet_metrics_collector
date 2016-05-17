test_name 'PE-15434 - - Install pe_support_script Module' do
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))
  meep_module_dir = '/opt/puppetlabs/server/data/enterprise/modules'

  # NOTE: This step is a temporary workaround for MEEP installation not being
  # supported by beaker-pe yet and can be removed once MEEP support is merged.
  step 'Mock MEEP' do
    hosts.each do |host|
      installer_dir = "#{host['working_dir']}/#{host['dist']}"

      on(host, "mkdir -p #{meep_module_dir}")
      on(host, puppet("module install #{installer_dir}/modules/*pe_manager*",
        modulepath: meep_module_dir))

      # Remove legacy PE support script.
      on(host, 'rm -rf /opt/puppetlabs/bin/puppet-enterprise-support /opt/puppetlabs/server/share/installer/utilities')
    end
  end

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
