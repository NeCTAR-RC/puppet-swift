class swift($swift_hash) {

  $openstack_version = hiera('openstack_version')

  package { 'swift':
    ensure => installed,
  }

  file { '/etc/swift':
    ensure  => directory,
    owner   => swift,
    group   => swift,
    mode    => '0775'
  }

  file { '/etc/swift/swift.conf':
    ensure  => present,
    owner   => swift,
    group   => swift,
    mode    => '0644',
    content => template("swift/${openstack_version}/swift.conf.erb"),
  }

}
