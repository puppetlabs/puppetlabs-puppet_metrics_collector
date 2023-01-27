# 
# @summary
#   Creates systemd units for collecting a given metric
# 
define puppet_metrics_collector::collect (
  Enum['present', 'absent'] $ensure          = 'present',
  String $metrics_type    = $title,
  String $metrics_command = undef,
  String $tidy_command    = undef,
  Optional[Hash] $env_vars   = undef,
  String $metric_ensure   = 'present',
  String $minute          = '5',
) {
  if $ensure == 'absent' {
    $services = [
      "puppet_${metrics_type}-metrics.service",
      "puppet_${metrics_type}-metrics.timer",
      "puppet_${metrics_type}-tidy.service",
      "puppet_${metrics_type}-tidy.timer"
    ]
    service { $services:
      ensure => stopped,
      enable => false,
    }

    $files = [
      "/etc/systemd/system/puppet_${metrics_type}-metrics.service",
      "/etc/systemd/system/puppet_${metrics_type}-metrics.timer",
      "/etc/systemd/system/puppet_${metrics_type}-tidy.service",
      "/etc/systemd/system/puppet_${metrics_type}-tidy.timer"
    ]

    file { $files:
      ensure => absent,
    }
  }
  else {
    $service_ensure = $metric_ensure ? {
      'present' => running,
      'absent'  => stopped,
    }

    $service_enable = $metric_ensure ? {
      'present' => true,
      'absent'  => false,
    }

    file { "/etc/systemd/system/puppet_${metrics_type}-metrics.service":
      ensure  => $metric_ensure,
      content => epp('puppet_metrics_collector/service.epp',
        { 'service' => "puppet_${metrics_type}", 'metrics_command' => $metrics_command, 'env_vars' => $env_vars }
      ),
    }
    file { "/etc/systemd/system/puppet_${metrics_type}-metrics.timer":
      ensure  => $metric_ensure,
      content => epp('puppet_metrics_collector/timer.epp',
        { 'service' => "puppet_${metrics_type}", 'minute' => $minute },
      ),
    }

    file { "/etc/systemd/system/puppet_${metrics_type}-tidy.service":
      ensure  => $metric_ensure,
      content => epp('puppet_metrics_collector/tidy.epp',
        { 'service' => "puppet_${metrics_type}", 'tidy_command' => $tidy_command }
      ),
    }
    file { "/etc/systemd/system/puppet_${metrics_type}-tidy.timer":
      ensure  => $metric_ensure,
      content => epp('puppet_metrics_collector/tidy_timer.epp',
        { 'service' => "puppet_${metrics_type}" }
      ),
    }

    service { "puppet_${metrics_type}-metrics.service":
    }
    service { "puppet_${metrics_type}-metrics.timer":
      ensure    => $service_ensure,
      enable    => $service_enable,
      subscribe => File["/etc/systemd/system/puppet_${metrics_type}-metrics.timer"],
    }

    service { "puppet_${metrics_type}-tidy.service": }
    service { "puppet_${metrics_type}-tidy.timer":
      ensure    => $service_ensure,
      enable    => $service_enable,
      subscribe => File["/etc/systemd/system/puppet_${metrics_type}-tidy.timer"],
    }
  }
}
