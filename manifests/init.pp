class swift($swift_hash, $converged_node=false) {

  $openstack_version = hiera('openstack_version')

  package { 'swift':
    ensure => installed,
  }

  file { '/etc/swift':
    ensure  => directory,
    owner   => swift,
    group   => swift,
    mode    => '0770',
    require => Package['swift'],
  }

  file { '/etc/swift/swift.conf':
    ensure  => present,
    owner   => swift,
    group   => swift,
    mode    => '0640',
    content => template("swift/${openstack_version}/swift.conf.erb"),
    require => File['/etc/swift'],
  }

}
