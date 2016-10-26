test_name 'PE-15434 - - Install Puppet Enterprise' do
  require 'beaker-pe-large-environments' # LEI install helpers

  step 'Install PE' do
    if hosts_as('compile_masters').empty?
      install_pe
    else
      install_lei
    end
  end
end
