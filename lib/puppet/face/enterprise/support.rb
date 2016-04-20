require 'puppet/indirector/face'
require 'fileutils'
require 'open-uri'
require 'tempfile'

Puppet::Face.define(:enterprise, '1.0.0') do
  action :support do
    summary "Collects information about your Puppet Enterprise installation for support"

    when_invoked do |options|
    end
  end
end


