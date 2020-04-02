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

}
