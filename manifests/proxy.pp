class swift::proxy inherits swift {
  if !$::swift_proxy_workers {
    $workers = 8
  }
  else {
    $workers = $::swift_proxy_workers
  }

  $total_procs = 1 + $workers

  package { 'swift-proxy':
    ensure  => present,
  }

  realize Package['python-keystone']

  file { '/etc/swift/proxy-server.conf':
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('swift/proxy-server.conf.erb'),
    require => Package['swift-proxy'],
  }

  service { 'swift-proxy':
    ensure     => running,
    enable     => true,
    subscribe  => File['/etc/swift/proxy-server.conf'],
  }

  if $::swift_protocol == 'https' {
    nagios::service {
      'http_swift-proxy_8888':
        check_command => 'check_swift_ssl!8888',
        servicegroups => 'openstack-endpoints';
    }
  }
  else {
    nagios::service {
      'http_swift-proxy_8888':
        check_command => 'check_swift!8888',
        servicegroups => 'openstack-endpoints';
    }
  }


  nagios::nrpe::service {
    'service_swift-proxy-server':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${total_procs}:${total_procs} -u swift -a /usr/bin/swift-proxy-server";
  }
}

class swift::proxy::nagios-checks {
  # These are checks that can be run by the nagios server.
  nagios::command {
    'check_swift_ssl':
      check_command => '/usr/lib/nagios/plugins/check_http --ssl -u /healthcheck -p \'$ARG1$\' -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
    'check_swift':
      check_command => '/usr/lib/nagios/plugins/check_http -u /healthcheck -p \'$ARG1$\' -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
    'check_swift_internal':
      check_command => '/usr/lib/nagios/plugins/check_http -p \'$ARG1$\' -e 400 -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
  }
}
