require 'puppet/indirector/face'
require 'puppet/feature/base'

# Primum non nocere

Puppet::Face.define(:enterprise, '1.0.0') do
  action :support do
    summary "Collects information about your Puppet Enterprise installation for support"

    when_invoked do |options|
      if Puppet.features.microsoft_windows?
        Puppet.err <<-EOS
The puppet enterprise support command isn't implemented for Windows
platforms at this time.
EOS

        exit 1
      end

      support_module = File.expand_path(File.join(File.dirname(__FILE__), '../../../..'))
      support_script = File.join(support_module, 'files/puppet-enterprise-support')

      Kernel.exec support_script
    end
  end
end
