# Openstack Swift
class swift(
  $swift_hash,
  $converged_node=false,
  $multi_daemon_config=false,
  $memcache_servers=undef,
) {

  $real_memcache_servers = pick($memcache_servers, hiera('swift::proxy::memcache_servers'))

  $openstack_version = hiera('openstack_version')

  package { 'swift':
    ensure => installed,
    tag    => 'openstack',
  }

  file { '/etc/swift':
    ensure  => directory,
    owner   => swift,
    group   => swift,
    mode    => '0770',
    require => Package['swift'],
  }

  file { '/etc/swift/swift.conf':
    owner   => swift,
    group   => swift,
    mode    => '0640',
    content => template("swift/${openstack_version}/swift.conf.erb"),
    require => File['/etc/swift'],
  }

  if $real_memcache_servers {
    include ::memcached

    file { '/etc/swift/memcache.conf':
      owner   => swift,
      group   => swift,
      content => template('swift/memcache.conf.erb'),
      require => File['/etc/swift'],
    }
  } else {
    file { '/etc/swift/memcache.conf':
      ensure => absent,
    }
  }
}
