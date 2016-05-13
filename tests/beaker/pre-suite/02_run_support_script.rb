test_name 'PE-15434 - - Run Support Script' do
  # NOTE: This can be removed once PE-15117 lands.
  meep_module_dir = '/opt/puppetlabs/server/data/enterprise/modules'

  step 'Run Support Script' do
    hosts.each do |host|
      result = on(host, puppet('enterprise support', modulepath: meep_module_dir))
      output_tarball = result.stdout.match(/^Support data is located at (.*)$/).captures.first

      stage_dir = create_tmpdir_on(host)
      on(host, "tar xzf #{output_tarball} -C #{stage_dir}")

      # Save path to extracted data in host object so that tests
      # can inspect it.
      host['support_script_output'] = File.join(stage_dir, File.basename(output_tarball, '.tar.gz'))
    end
  end
end
