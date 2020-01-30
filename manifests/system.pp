class puppet_metrics_collector::system (
  String        $output_dir                    = '/opt/puppetlabs/puppet-metrics-collector',
  Integer       $collection_frequency          = 5, #minutes
  Integer       $polling_frequency_seconds     = 1,
  Integer       $retention_days                = 90,
  String        $system_metrics_ensure         = present,
  Boolean       $symlink_puppet_metrics_collector = true,
  Boolean       $manage_sysstat = true,
) {
  $scripts_dir = "${output_dir}/scripts"
  $bin_dir     = "${output_dir}/bin"

  #assume if output is defined, all of the rest will be too as the init.pp must be in use
  #and thus we don't need to redefine these
  if ! defined(File[$output_dir]) {
    file { [ $output_dir, $scripts_dir, $bin_dir]:
      ensure => directory,
    }

    file { "${bin_dir}/puppet-metrics-collector":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => epp('puppet_metrics_collector/puppet-metrics-collector.epp', {
        'output_dir' => $output_dir,
      }),
    }

    $symlink_ensure = $symlink_puppet_metrics_collector ? {
      false => 'absent',
      true  => 'symlink',
    }

    file { '/opt/puppetlabs/bin/puppet-metrics-collector':
      ensure => $symlink_ensure,
      target => "${bin_dir}/puppet-metrics-collector",
    }
  }

  file { "${scripts_dir}/generate_system_metrics":
    ensure => present,
    mode   => '0755',
    source => 'puppet:///modules/puppet_metrics_collector/generate_system_metrics'
  }

  if $manage_sysstat {
    package { 'sysstat':
      ensure => installed,
    }
  }

  include puppet_metrics_collector::system_cpu
  include puppet_metrics_collector::system_memory
  include puppet_metrics_collector::processes
}
