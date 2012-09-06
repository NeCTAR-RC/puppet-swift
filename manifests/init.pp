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
    owner   => root,
    group   => root,
    content => template('swift/swift.conf.erb'),
  }

}
