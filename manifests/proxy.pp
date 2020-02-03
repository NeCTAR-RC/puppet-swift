# Swift Proxy class
class swift::proxy(
  $storage_domain,
  $keystone_user,
  $keystone_password,
  $listen='0.0.0.0',
  $port=8888,
  $ssl=true,
  $workers=8,
  $read_affinity=false,
  $write_affinity=false,
  $write_affinity_node_count=1,
  $account_autocreate=true,
  $secret_cache_duration=3600,
) inherits swift {

  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')

  $total_procs = 1 + $workers

  $openstack_version = hiera('openstack_version')
  if $openstack_version[0] > 'r' {
    package { 'swift-proxy':
      ensure => present,
      tag    => 'openstack',
    }
  }
  else {
    package { ['swift-proxy', 'swift-plugin-s3', 'python-keystonemiddleware']:
      ensure => present,
      tag    => 'openstack',
    }
  }

  file { '/etc/swift/proxy-server.conf':
    ensure  => file,
    owner   => swift,
    group   => swift,
    content => template("swift/${openstack_version}/proxy-server.conf.erb"),
    notify  => Service['swift-proxy'],
    require => Package['swift-proxy'],
  }

  service { 'swift-proxy':
    ensure    => running,
    enable    => true,
    subscribe => [File['/etc/swift/swift.conf'],
                  File['/etc/swift/memcache.conf']],
  }

  firewall { '100 swift-proxy':
    dport  => $port,
    proto  => tcp,
    action => accept,
  }

  if $ssl {
    nagios::service {
      'https_swift-proxy':
        check_command => "check_swift_ssl!${port}",
        servicegroups => 'openstack-endpoints';
    }
  }
  else {
    nagios::service {
      'http_swift-proxy':
        check_command => "check_swift!${port}",
        servicegroups => 'openstack-endpoints';
    }
  }

  nagios::nrpe::service {
    'service_swift-proxy-server':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${total_procs}:${total_procs} -u swift -a /usr/bin/swift-proxy-server";
  }

  nagios::nrpe::service {
    'swift_object_servers':
      check_command => 'sudo /usr/local/lib/nagios/plugins/check_swift_object_servers',
      nrpe_command  => 'check_nrpe_slow_1arg',
  }

  file { '/usr/local/lib/nagios/plugins/check_swift_object_servers':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0775',
    source => 'puppet:///modules/swift/check_swift_object_servers',
  }

  file { '/etc/sudoers.d/nagios_swift_object_servers':
    owner  => root,
    group  => root,
    mode   => '0440',
    source => 'puppet:///modules/swift/sudoers_nagios_swift_object_servers',
  }

  $nagios_keystone_user = hiera('nagios::keystone_user')
  $nagios_keystone_pass = hiera('nagios::keystone_pass')
  $nagios_keystone_tenant = hiera('nagios::keystone_tenant')
  $nagios_swift_region = hiera('nagios::swift_region', '')

  nagios::service { 'check_swift':
    check_command => "check_swift_operations!${keystone_protocol}://${keystone_host}:5000/v3/!${nagios_keystone_user}!${nagios_keystone_pass}!${nagios_keystone_tenant}!${nagios_swift_region}";
  }
}
