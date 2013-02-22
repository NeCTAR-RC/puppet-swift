class swift($swift_hash) {

  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $keystone_user = hiera('swift::keystone_user')
  $keystone_password = hiera('swift::keystone_password')

  package { 'swift':
    ensure => installed,
  }

  file { '/etc/swift':
    ensure  => directory,
    owner   => swift,
    group   => swift,
  }

  file { '/etc/swift/swift.conf':
    ensure  => present,
    owner   => swift,
    group   => swift,
    mode    => '0640',
    content => template("swift/${openstack_version}/swift.conf.erb"),
  }

}
