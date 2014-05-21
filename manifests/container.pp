class swift::container($workers=2) inherits swift {

  $total_procs = 1 + $workers

  package { 'swift-container':
    ensure => present,
  }

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

  if $converged_node == false {
    swift::ringcopy { ['container']: }
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
