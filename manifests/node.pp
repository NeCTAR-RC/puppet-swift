class swift::node($rsync_connections=2) inherits swift {

  file { '/etc/rsyncd.conf':
    ensure  => present,
    content => template("swift/${openstack_version}/rsync.conf.erb"),
  }

  file { '/etc/default/rsync':
    ensure => present,
    source => 'puppet:///modules/swift/rsync',
  }

  file { '/etc/logrotate.d/rsyncd':
    ensure => file,
    source => 'puppet:///modules/swift/logrotate',
  }

  service { 'rsync':
    ensure     => running,
    enable     => true,
    subscribe  => [ File['/etc/rsyncd.conf'],
                    File['/etc/default/rsync']],
  }

  file { '/srv/node':
    ensure => directory,
    owner  => swift,
    group  => swift,
 }

  package { 'xfsprogs':
    ensure => installed,
  }

  file {'/var/cache/swift':
    owner => swift,
    group => swift,
  }

  file {'/etc/swift/drive-audit.conf':
    owner   => swift,
    group   => swift,
    content => template('swift/drive-audit.conf.erb')
  }

  cron { 'drive-audit':
    ensure  => present,
    command => 'swift-drive-audit /etc/swift/drive-audit.conf',
    user    => 'root',
    minute  => 0,
    require => File['/etc/swift/drive-audit.conf'],
  }

 cron { 'swift-recon':
   ensure  => present,
   command => '/usr/bin/swift-recon-cron /etc/swift/object-server.conf',
   user    => 'swift',
   minute  => 5,
   require => File['/etc/swift/object-server.conf'],
 }

  file { '/etc/sysctl.d/60-swift.conf':
    owner  => root,
    group  => root,
    mode   => 0644,
    source => 'puppet:///modules/swift/60-swift-sysctl.conf',
    notify => Exec[sysctl-swift],
  }

  exec { 'sysctl-swift':
    command     => '/sbin/sysctl -p /etc/sysctl.d/60-swift.conf',
    unless      => '/usr/bin/test `sysctl -e -n net.nf_conntrack_max` -eq 262144',
  }

  $stg_hosts = hiera('firewall::swift_storage_hosts', [])
  firewall::multisource {[ prefix($stg_hosts, '100 swift-node,') ]:
    proto  => 'tcp',
    dport  => [873, 6000, 6001, 6002],
    action => accept,
  }

  include swift::object
  include swift::container
  include swift::account

}
