class swift::container {

  if !$::swift_container_workers {
    $workers = 2
    } else {
    $workers = $::swift_container_workers
  }

  $total_procs = 1 + $workers

  package { 'swift-container':
    ensure => present,
  }

  file { '/etc/swift/container-server.conf':
    ensure  => present,
    owner   => swift,
    group   => swift,
    require => Package['swift-container'],
    content => template('swift/container-server.conf.erb'),
  }

  service { 'swift-container':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/swift/container-server.conf'],
  }

  service { 'swift-container-replicator':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/swift/container-server.conf'],
  }

  service { 'swift-container-updater':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/swift/container-server.conf'],
  }

  service { 'swift-container-auditor':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/swift/container-server.conf'],
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
