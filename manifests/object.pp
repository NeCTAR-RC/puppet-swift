class swift::object($workers=2) {

  $openstack_version = hiera('openstack_version')
  $dedicated_replication = hiera('swift::object::dedicated_replication')
  $object_replication_port = hiera('swift::object::object_replication_port')
  $total_procs = 1 + $workers

  package { 'swift-object':
    ensure => present,
  }

if $dedicated_replication == true {    
   file { "/etc/swift/object-server":
   ensure => "directory",
   owner => "swift",
   group => "swift",
   mode => 750,    
   }   
   #request config     
    file { '/etc/swift/object-server/request.conf':
     ensure  => present,
     owner   => swift,
     group   => swift,
     require => Package['swift-object'],
     content => template("swift/${openstack_version}/object-server/request.conf.erb"),
    }
   
   #replication config     
   file { '/etc/swift/object-server/replication.conf':
    ensure  => present,
    owner   => swift,
    group   => swift,
    require => Package['swift-object'],
    content => template("swift/${openstack_version}/object-server/replication.conf.erb"),
  }
 
     exec {'start_object_server':
        command => '/usr/bin/swift-init object-server start',
        subscribe => [ File['/etc/swift/object-server/request.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
      }
     exec {'start_object_replicator':
        command => '/usr/bin/swift-init object-replicator start',
        subscribe => [ File['/etc/swift/object-server/replication.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
     }  
     exec {'start_object_reaper':
        command => '/usr/bin/swift-init object-reaper start',
        subscribe => [ File['/etc/swift/object-server/request.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
     }
     exec {'start_object_auditor':
        command => '/usr/bin/swift-init object-auditor start',
        subscribe => [ File['/etc/swift/object-server/request.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
      }
    file { '/etc/swift/object-server.conf':
    ensure  => absent,
    }
  }

else {

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
 }

  nagios::service {
    'http_swift-object_6000':
      check_command => 'check_swift_internal!6000';
  }

  nagios::nrpe::service {
    'service_swift-object-server':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${total_procs}:${total_procs} -u swift -a /usr/bin/swift-object-server";
    'service_swift-object-updater':
      check_command => "/usr/lib/nagios/plugins/check_procs -c 1:${workers} -u swift -a /usr/bin/swift-object-updater";
    'service_swift-object-replicator':
      check_command => "/usr/lib/nagios/plugins/check_procs -c 1:${workers} -u swift -a /usr/bin/swift-object-replicator";
    'service_swift-object-auditor':
      check_command => "/usr/lib/nagios/plugins/check_procs -c 1:${workers} -u swift -a /usr/bin/swift-object-auditor";
  }

}
