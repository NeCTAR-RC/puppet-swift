class swift {

  package { 'swift':
    ensure => installed,
  }

  file { '/etc/swift':
    ensure  => directory,
    owner   => swift,
    group   => swift,
  }

  file { '/etc/swift/swift.conf':
    ensure  => file,
    owner   => swift,
    group   => swift,
    content => template("swift/${openstack_version}/swift.conf.erb"),
  }

}
