class swift::account($workers=2) {

  $openstack_version = hiera('openstack_version')
  $dedicated_replication = hiera('swift::account::dedicated_replication')
  $account_replication_port = hiera('swift::account::account_replication_port')
  $total_procs = 1 + $workers

  package { 'swift-account':
    ensure => present,
  }


if $dedicated_replication == true {    
   file { "/etc/swift/account-server":
   ensure => "directory",
   owner => "swift",
   group => "swift",
   mode => 750,    
   }   
   #request config     
    file { '/etc/swift/account-server/request.conf':
     ensure  => present,
     owner   => swift,
     group   => swift,
     require => Package['swift-account'],
     content => template("swift/${openstack_version}/account-server/request.conf.erb"),
    }   
   
   #replication config     
   file { '/etc/swift/account-server/replication.conf':
    ensure  => present,
    owner   => swift,
    group   => swift,
    require => Package['swift-account'],
    content => template("swift/${openstack_version}/account-server/replication.conf.erb"),
  }

     exec {'start_account_server':
        command => '/usr/bin/swift-init account-server start',
        subscribe => [ File['/etc/swift/account-server/request.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
      }   
     exec {'start_account_replicator':
        command => '/usr/bin/swift-init account-replicator start',
        subscribe => [ File['/etc/swift/account-server/replication.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
     }   
     exec {'start_account_reaper':
        command => '/usr/bin/swift-init account-reaper start',
        subscribe => [ File['/etc/swift/account-server/request.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
     }   
     exec {'start_account_auditor':
        command => '/usr/bin/swift-init account-auditor start',
        subscribe => [ File['/etc/swift/account-server/request.conf'],
                       File['/etc/swift/swift.conf']],
        refreshonly => true,
        returns => [0,1]
      }   
    file { '/etc/swift/account-server.conf':
    ensure  => absent,
    }

  }

else {
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

 }
  nagios::service {
    'http_swift-account_6002':
      check_command => 'check_swift_internal!6002';
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
