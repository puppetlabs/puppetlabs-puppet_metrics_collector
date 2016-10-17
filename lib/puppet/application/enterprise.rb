require 'puppet/application/face_base'

# This subcommand is implemented as a face. The definition of the application
# can be found in face/enterprise.rb.
class Puppet::Application::Enterprise < Puppet::Application::FaceBase
  # Call Puppet's settings.use method (which is idempotent) during the
  # application's setup phase to have it create all necessary objects and
  # directories for a PE install via a puppet apply.
  #
  def setup
    super
    Puppet.settings.use(:main)
  end
end
