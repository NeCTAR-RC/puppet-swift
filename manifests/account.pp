class swift::account($workers=2) {

  $openstack_version = hiera('openstack_version')
  $total_procs = 1 + $workers

  package { 'swift-account':
    ensure => present,
  }

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
