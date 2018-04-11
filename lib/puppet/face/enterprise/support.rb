require 'puppet/indirector/face'
require 'puppet/feature/base'

# Primum non nocere

Puppet::Face.define(:enterprise, '1.0.0') do
  action :support do
    summary "Collects information about your Puppet Enterprise installation for support"

    option '--classifier' do
      summary 'Toggle to pull classification data.'
    end

    option '--encrypt' do
      summary 'Toggle to GPG encrypt the resulting tarball.'
    end

    option '--dir DIRECTORY' do
      summary 'Optional output directory.'
      default_to { '' }
    end

    option '--log-age NUMBER|all' do
      summary 'Maximum age in days of logfiles to collect. Defaults to 14, "all" may be used to collect all files.'
      default_to { '14' }
    end

    option '--ticket NUMBER' do
      summary 'Optional support ticket number.'
      default_to { '' }
    end

    when_invoked do |options|
      if Puppet.features.microsoft_windows?
        Puppet.err <<-EOS
The puppet enterprise support command isn't implemented for Windows platforms at this time.
EOS
        exit 1
      end

      os_family = %x{/opt/puppetlabs/puppet/bin/facter os.family}.chomp.strip
      unless ['redhat', 'debian', 'suse'].include? os_family.downcase
        Puppet.err <<-EOS
The puppet enterprise support command isn't implemented for #{os_family} platforms at this time.
EOS
        exit 1
      end

      support_script_parameters = []

      if options[:classifier]
        support_script_parameters.push("-c")
      end

      if options[:encrypt]
        support_script_parameters.push("-e")
      end

      if options[:dir] != ''
        support_script_parameters.push("-d#{options[:dir]}")
      end

      unless options[:log_age].nil?
        if options[:log_age].match(/\Aall|[0-9]+\Z/)
          support_script_parameters.push("-l#{options[:log_age]}")
        else
          Puppet.err("The argument to --log-age must be a number or the string 'all'. Got: #{options[:log_age]}")
          exit 1
        end
      end

      if options[:ticket] != ''
        if options[:ticket] =~ /^[a-zA-Z0-9\-]+$/
          support_script_parameters.push("-t#{options[:ticket]}")
        else
          Puppet.err "The ticket parameter may contain only numbers, letters, and dashes."
          exit 1
        end
      end

      support_module = File.expand_path(File.join(File.dirname(__FILE__), '../../../..'))
      support_script = File.join(support_module, 'lib/puppet_x/puppetlabs/support_script/v1/puppet-enterprise-support.sh')

      Kernel.exec('/bin/bash', support_script, *support_script_parameters)
    end
  end
end
