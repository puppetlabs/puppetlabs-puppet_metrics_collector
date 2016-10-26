test_name 'PE-15434 - - Run Support Script' do
  hosts.each do |host|
    step "Run Support Script on #{host.name} : #{host['roles'].join(',')}" do
      result = on(host, puppet('enterprise support'))
      output_tarball = result.stdout.match(/^Support data is located at (.*)$/).captures.first

      stage_dir = create_tmpdir_on(host)
      on(host, "tar xzf #{output_tarball} -C #{stage_dir}")

      # Save path to extracted data in host object so that tests
      # can inspect it.
      host['support_script_output'] = File.join(stage_dir, File.basename(output_tarball, '.tar.gz'))
    end
  end
end
