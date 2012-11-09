class swift::node inherits swift {

  file { '/etc/rsyncd.conf':
    ensure  => present,
    content => template("swift/${openstack_version}/rsync.conf.erb"),
  }

  file { '/etc/default/rsync':
    ensure => present,
    source => 'puppet:///modules/swift/rsync',
  }

  service { 'rsync':
    ensure     => running,
    enable     => true,
    subscribe  => [ File['/etc/rsyncd.conf'],
                    File['/etc/default/rsync']],
  }

  file { '/srv/node':
    ensure => directory,
  }

  package { 'xfsprogs':
    ensure => installed,
  }

  file {'/var/cache/swift':
    owner => swift,
    group => swift,
  }

  include swift::object
  include swift::container
  include swift::account

}
