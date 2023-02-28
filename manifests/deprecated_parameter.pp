define puppet_metrics_collector::deprecated_parameter () {
  $value = getvar($title)

  if $title =~ /::metrics_server_type$/ and ( $value != 'splunk_hec' and $value != undef) {
    notify { "Invalid value for ${title}":
      message  => "Only 'splunk_hec' is a valid value for the ${title} parameter; however, it has been set to '${value}'. Please remove it from your Classifier classification, hiera data or /etc/puppetlabs/enterprise/conf.d/pe.conf, as appropriate.",
      loglevel => 'warning',
    }
  }
  elsif $value != undef {
    notify { "${title} is deprecated":
      message  => "The ${title} parameter is deprecated and will be removed in a future release; however, it has been set to '${value}'. Please remove it from your Classifier classification, hiera data or /etc/puppetlabs/enterprise/conf.d/pe.conf, as appropriate.",
      loglevel => 'warning',
    }
  }
}
