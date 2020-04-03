class swift::container($workers=2, $allow_versions=false) inherits swift {

  package { 'swift-container':
    ensure => present,
    tag    => 'openstack',
  }

  if $swift::multi_daemon_config == false {

    file { '/etc/swift/container-server.conf':
      ensure  => present,
      owner   => swift,
      group   => swift,
      require => Package['swift-container'],
      content => template("swift/${openstack_version}/container-server.conf.erb"),
    }

    service { 'swift-container':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/container-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-container-replicator':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/container-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-container-updater':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/container-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-container-auditor':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/container-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

  } else {

    $ipaddress_regnet = hiera('swift::ipaddress_regnet')
    $ipaddress_repnet = hiera('swift::ipaddress_repnet')
    $container_rep_port = hiera('swift::container::container_rep_port')

    file { '/etc/swift/container-server.conf':
      ensure  => absent,
      require => Package['swift-container'],
    }

    file { '/etc/swift/container-server':
      ensure => directory,
      owner  => swift,
      group  => swift,
      require => Package['swift-container'],
    }

    file { '/etc/swift/container-server/1.conf':
      ensure  => present,
      owner   => swift,
      group   => swift,
      require => [ Package['swift-container'],
                   File['/etc/swift/container-server']],
      content => template("swift/${openstack_version}/multi_daemon_config/container-server-reg.conf.erb"),
    }

    file { '/etc/swift/container-server/2.conf':
      ensure  => present,
      owner   => swift,
      group   => swift,
      require => [ Package['swift-container'],
                   File['/etc/swift/container-server']],
      content => template("swift/${openstack_version}/multi_daemon_config/container-server-rep.conf.erb"),
    }

    file { '/etc/init/swift-container.conf':
      ensure  => present,
      require => Package['swift-container'],
      source  => 'puppet:///modules/swift/swift_init/swift-container.conf'
    }

    file { '/etc/init/swift-container-replicator.conf':
      ensure  => present,
      require => Package['swift-container'],
      source  => 'puppet:///modules/swift/swift_init/swift-container-replicator.conf'
    }

    file { '/etc/init/swift-container-updater.conf':
      ensure  => present,
      require => Package['swift-container'],
      source  => 'puppet:///modules/swift/swift_init/swift-container-updater.conf'
    }

    file { '/etc/init/swift-container-auditor.conf':
      ensure  => present,
      require => Package['swift-container'],
      source  => 'puppet:///modules/swift/swift_init/swift-container-auditor.conf'
    }

    service { 'swift-container':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-container.conf'],
      subscribe => [ File['/etc/swift/container-server/1.conf'],
                     File['/etc/swift/container-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-container-replicator':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-container-replicator.conf'],
      subscribe => [ File['/etc/swift/container-server/1.conf'],
                     File['/etc/swift/container-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-container-updater':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-container-updater.conf'],
      subscribe => [ File['/etc/swift/container-server/1.conf'],
                     File['/etc/swift/container-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-container-auditor':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-container-auditor.conf'],
      subscribe => [ File['/etc/swift/container-server/1.conf'],
                     File['/etc/swift/container-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

  }

}
