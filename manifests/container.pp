class swift::container($workers=2) {

  $openstack_version = hiera('openstack_version')
  $dedicated_replication = hiera('swift::container::dedicated_replication')
  $container_replication_port = hiera('swift::container::container_replication_port')
  $total_procs = 1 + $workers

  package { 'swift-container':
    ensure => present,
  }

if $dedicated_replication == true {

    file { "/etc/swift/container-server":
          ensure => "directory",
          owner => "swift",
          group => "swift",
          mode => 750,
        }

    #request config
    file { '/etc/swift/container-server/request.conf':
     ensure  => present,
     owner   => swift,
     group   => swift,
     require => Package['swift-container'],
     content => template("swift/${openstack_version}/container-server/request.conf.erb"),
    }

   #replication config
   file { '/etc/swift/container-server/replication.conf':
    ensure  => present,
    owner   => swift,
    group   => swift,
    require => Package['swift-container'],
    content => template("swift/${openstack_version}/container-server/replication.conf.erb"),
  }

     exec {'start_container_server':
        command => '/usr/bin/swift-init container-server start',
        subscribe => [ File['/etc/swift/container-server/request.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
      }
     exec {'start_container_replicator':
        command => '/usr/bin/swift-init container-replicator start',
        subscribe => [ File['/etc/swift/container-server/replication.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
     } 
     exec {'start_container_reaper':
        command => '/usr/bin/swift-init container-reaper start',
        subscribe => [ File['/etc/swift/container-server/request.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
     }
     exec {'start_container_auditor':
        command => '/usr/bin/swift-init container-auditor start',
        subscribe => [ File['/etc/swift/container-server/request.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
      }

    file { '/etc/swift/container-server.conf':
    ensure  => absent,
    }
  }

else {
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
}

  nagios::service {
    'http_swift-container_6001':
      check_command => 'check_swift_internal!6001';
  }

  nagios::nrpe::service {
    'service_swift-container-server':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${total_procs}:${total_procs} -u swift -a /usr/bin/swift-container-server";
    'service_swift-container-replicator':
      check_command => "/usr/lib/nagios/plugins/check_procs -c 1:${workers} -u swift -a /usr/bin/swift-container-replicator";
    'service_swift-container-updater':
      check_command => "/usr/lib/nagios/plugins/check_procs -c 1:${workers} -u swift -a /usr/bin/swift-container-updater";
  }

}
