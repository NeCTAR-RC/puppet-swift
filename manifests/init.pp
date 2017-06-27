# Openstack Swift
class swift($swift_hash,
            $converged_node=false,
            $multi_daemon_config=false,
            $enable_ceilometer=false) {

  $openstack_version = hiera('openstack_version')

  # Brief Description: 
  # These values define threshold limits (in seconds)
  # for replicating swift accounts, containers and 
  # objects. Warning and critical nagios alerts are 
  # triggerred above these values
  # Current Values:
  # WARNING: 3 hours
  # CRITICAL: 8 Hours

  $nagios_warning_threshold = 10800
  $nagios_critical_threshold = 28800

  package { 'swift':
    ensure => installed,
  }

  file { '/etc/swift':
    ensure  => directory,
    owner   => swift,
    group   => swift,
    mode    => '0770',
    require => Package['swift'],
  }

  file { '/etc/swift/swift.conf':
    ensure  => present,
    owner   => swift,
    group   => swift,
    mode    => '0640',
    content => template("swift/${openstack_version}/swift.conf.erb"),
    require => File['/etc/swift'],
  }

}
