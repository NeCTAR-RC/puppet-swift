class swift::account($workers=2) {

  $openstack_version = hiera('openstack_version')
  $total_procs = 1 + $workers
  $multi_daemon_config = hiera('swift::multi_daemon_config')

  package { 'swift-account':
    ensure => present,
  }

  if $multi_daemon_config == false {

    file { '/etc/swift/account-server.conf':
      ensure  => present,
      owner   => swift,
      group   => swift,
      require => Package['swift-account'],
      content => template("swift/${openstack_version}/account-server.conf.erb"),
    }

    service { 'swift-account':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/account-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-account-replicator':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/account-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-account-auditor':
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/swift/account-server.conf'],
                     File['/etc/swift/swift.conf']],
    }

  } else {

    $ipaddress_regnet = hiera('swift::ipaddress_regnet')
    $ipaddress_repnet = hiera('swift::ipaddress_repnet')
    $account_rep_port = hiera('swift::account::account_rep_port')

    file { '/etc/swift/account-server.conf':
      ensure  => absent,
      require => Package['swift-account'],
    }

    file { '/etc/swift/account-server':
      ensure => directory,
      owner  => swift,
      group  => swift,
      require => Package['swift-account'],
    }

    file { '/etc/swift/account-server/1.conf':
      ensure  => present,
      owner   => swift,
      group   => swift,
      require => [ Package['swift-account'],
                   File['/etc/swift/account-server']],
      content => template("swift/${openstack_version}/multi_daemon_config/account-server-reg.conf.erb"),
    }

    file { '/etc/swift/account-server/2.conf':
      ensure  => present,
      owner   => swift,
      group   => swift,
      require => [ Package['swift-account'],
                   File['/etc/swift/account-server']],
      content => template("swift/${openstack_version}/multi_daemon_config/account-server-rep.conf.erb"),
    }

    file { '/etc/init/swift-account.conf':
      ensure  => present,
      require => Package['swift-account'],
      source  => 'puppet:///modules/swift/swift_init/swift-account.conf'
    }

    file { '/etc/init/swift-account-replicator.conf':
      ensure  => present,
      require => Package['swift-account'],
      source  => 'puppet:///modules/swift/swift_init/swift-account-replicator.conf'
    }

    file { '/etc/init/swift-account-auditor.conf':
      ensure  => present,
      require => Package['swift-account'],
      source  => 'puppet:///modules/swift/swift_init/swift-account-auditor.conf'
    }

    file { '/etc/init/swift-account-reaper.conf':
      ensure  => present,
      require => Package['swift-account'],
      source  => 'puppet:///modules/swift/swift_init/swift-account-reaper.conf'
    }

    service { 'swift-account':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-account.conf'],
      subscribe => [ File['/etc/swift/account-server/1.conf'],
                     File['/etc/swift/account-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-account-replicator':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-account-replicator.conf'],
      subscribe => [ File['/etc/swift/account-server/1.conf'],
                     File['/etc/swift/account-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-account-auditor':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-account-auditor.conf'],
      subscribe => [ File['/etc/swift/account-server/1.conf'],
                     File['/etc/swift/account-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

    service { 'swift-account-reaper':
      ensure    => running,
      enable    => true,
      require   => File['/etc/init/swift-account-reaper.conf'],
      subscribe => [ File['/etc/swift/account-server/1.conf'],
                     File['/etc/swift/account-server/2.conf'],
                     File['/etc/swift/swift.conf']],
    }

  }

  swift::ringcopy { ['account']: }

  nagios::service {
    'http_swift-account_6002':
      check_command => 'check_swift_internal!6002';
  }

  if $multi_daemon_config == true {
    nagios::service {
      'http_swift-account_6012':
        check_command => 'check_swift_internal!6012';
    }
  }

  nagios::nrpe::service {
    'service_swift-account-server':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${total_procs}:${total_procs} -u swift -a /usr/bin/swift-account-server";
    'service_swift-account-replicator':
      check_command => "/usr/lib/nagios/plugins/check_procs -c 1:${workers} -u swift -a /usr/bin/swift-account-replicator";
    'service_swift-account-auditor':
      check_command => "/usr/lib/nagios/plugins/check_procs -c 1:${workers} -u swift -a /usr/bin/swift-account-auditor";
  }

}
