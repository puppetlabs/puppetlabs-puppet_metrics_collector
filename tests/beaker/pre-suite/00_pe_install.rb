test_name 'PE-15434 - - Install Puppet Enterprise' do
  if hosts_as('compile_master').empty?
    step 'Install PE' do
      install_pe
    end
  else
    require 'beaker-pe-large-environments'

    step 'Install PE LEI' do
      install_lei
    end
  end
end
