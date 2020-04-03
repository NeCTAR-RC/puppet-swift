# Install and config swift object components

class swift::object(
  $workers=2,
  $rsync_timeout=3600,
  $rsync_io_timeout=undef,
  $lockup_timeout=undef,
  $rsync_bwlimit=undef
  ) inherits swift {

  package { 'swift-object':
    ensure => present,
    tag    => 'openstack',
  }

  if $swift::multi_daemon_config == false {

    file { '/etc/swift/object-server.conf':
      ensure  => present,
      owner   => swift,
      group   => swift,
      require => Package['swift-object'],
      content => template("swift/${openstack_version}/object-server.conf.erb"),
    }

    service { 'swift-object':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/object-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-object-replicator':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/object-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-object-updater':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/object-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-object-auditor':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/object-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

  } else {

    $ipaddress_regnet = hiera('swift::ipaddress_regnet')
    $ipaddress_repnet = hiera('swift::ipaddress_repnet')
    $object_rep_port = hiera('swift::object::object_rep_port')

    file { '/etc/swift/object-server.conf':
      ensure  => absent,
      require => Package['swift-object'],
    }

    file { '/etc/swift/object-server':
      ensure => directory,
      owner  => swift,
      group  => swift,
      require => Package['swift-object'],
    }

    file { '/etc/swift/object-server/1.conf':
      ensure  => present,
      owner   => swift,
      group   => swift,
      require => [ Package['swift-object'],
                   File['/etc/swift/object-server']],
      content => template("swift/${openstack_version}/multi_daemon_config/object-server-reg.conf.erb"),
    }

    file { '/etc/swift/object-server/2.conf':
      ensure  => present,
      owner   => swift,
      group   => swift,
      require => [ Package['swift-object'],
                   File['/etc/swift/object-server']],
      content => template("swift/${openstack_version}/multi_daemon_config/object-server-rep.conf.erb"),
    }

    file { '/etc/init/swift-object.conf':
      ensure  => present,
      require => Package['swift-object'],
      source  => 'puppet:///modules/swift/swift_init/swift-object.conf'
    }

    file { '/etc/init/swift-object-replicator.conf':
      ensure  => present,
      require => Package['swift-object'],
      source  => 'puppet:///modules/swift/swift_init/swift-object-replicator.conf'
    }

    file { '/etc/init/swift-object-updater.conf':
      ensure  => present,
      require => Package['swift-object'],
      source  => 'puppet:///modules/swift/swift_init/swift-object-updater.conf'
    }

    file { '/etc/init/swift-object-auditor.conf':
      ensure  => present,
      require => Package['swift-object'],
      source  => 'puppet:///modules/swift/swift_init/swift-object-auditor.conf'
    }

    service { 'swift-object':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-object.conf'],
      subscribe => [ File['/etc/swift/object-server/1.conf'],
                     File['/etc/swift/object-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-object-replicator':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-object-replicator.conf'],
      subscribe => [ File['/etc/swift/object-server/1.conf'],
                     File['/etc/swift/object-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-object-updater':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-object-updater.conf'],
      subscribe => [ File['/etc/swift/object-server/1.conf'],
                     File['/etc/swift/object-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-object-auditor':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-object-auditor.conf'],
      subscribe => [ File['/etc/swift/object-server/1.conf'],
                     File['/etc/swift/object-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

  }

}
