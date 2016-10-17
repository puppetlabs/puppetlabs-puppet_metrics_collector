require 'puppet/indirector/face'

Puppet::Face.define(:enterprise, '1.0.0') do
  copyright "Puppet", 2016
  license   "Puppet Enterprise Software License Agreement"

  summary "Commands to facilitate support of Puppet Enterprise."
  description <<-'EOT'
    This subcommand uses Puppet to collect information about your Puppet 
    Enterprise installation for support.
  EOT

  action :help do
    default
    summary "Display help about the enterprise subcommand."
    when_invoked do |*args|
      Puppet::Face[:help, '0.0.1'].help('enterprise')
    end
  end
end
