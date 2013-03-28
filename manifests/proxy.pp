class swift::proxy($keystone_user, $keystone_password, $workers=8, $protocol='https', $memcache_servers) inherits swift {

  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $total_procs = 1 + $workers

  package { 'swift-proxy':
    ensure  => present,
  }

  if $openstack_version == 'folsom' {
    package { 'swift-plugin-s3':
      ensure => installed,
    }
  }
  
  realize Package['python-keystone']

  file { '/etc/swift/proxy-server.conf':
    ensure  => file,
    owner   => swift,
    group   => swift,
    content => template("swift/${openstack_version}/proxy-server.conf.erb"),
    notify  => Service['swift-proxy'],
    require => Package['swift-proxy'],
  }

  file { '/etc/swift/memcache.conf':
    ensure  => file,
    owner   => swift,
    group   => swift,
    content => template("swift/${openstack_version}/memcache.conf.erb"),
    notify  => Service['swift-proxy'],
    require => Package['swift-proxy'],
  }

  service { 'swift-proxy':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/swift/swift.conf'],
  }

  if $protocol == 'https' {
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

  nagios::nrpe::service {
    'swift_object_servers':
      check_command => "/usr/local/lib/nagios/plugins/check_swift_object_servers"
  }

  file {'/usr/local/lib/nagios/plugins/check_swift_object_servers':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0775',
    source => 'puppet:///modules/glance/check_swift_object_servers',
  }

  $nagios_keystone_user = hiera('nagios::keystone_user')
  $nagios_keystone_pass = hiera('nagios::keystone_pass')
  $nagios_keystone_tenant = hiera('nagios::keystone_tenant')
  $nagios_image_count = hiera('nagios::image_count')
  $nagios_image = hiera('nagios::image')

  nagios::service {
    'check_swift':
      check_command => "check_swift_operations!${keystone_protocol}://${keystone_host}:5000/v2.0/!${nagios_keystone_user}!${nagios_keystone_pass}!${nagios_keystone_tenant}";
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
    'check_swift_operations':
      check_command => '/usr/local/lib/nagios/plugins/check_swift -A \'$ARG1$\' -U \'$ARG2$\' -P \'$ARG3$\' -T \'$ARG4$\' -c nagios';
  }

  file {'/usr/local/lib/nagios/plugins/check_swift':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0775',
    source => 'puppet:///modules/glance/check_swift',
  }

}
