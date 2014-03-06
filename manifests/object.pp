class swift::object($workers=2) {

  $openstack_version = hiera('openstack_version')
  $total_procs = 1 + $workers

  package { 'swift-object':
    ensure => present,
  }

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

  swift::ringcopy { ['object']: }

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
