class swift::node($rsync_connections=2, $max_connections=262144) inherits swift {

  file { '/etc/rsyncd.conf':
    ensure  => present,
    content => template("swift/${openstack_version}/rsync.conf.erb"),
  }

  file { '/etc/default/rsync':
    ensure => present,
    source => 'puppet:///modules/swift/rsync',
  }

  logrotate::rule { 'rsyncd':
    path    => '/var/log/rsyncd.log',
    options => [ 'rotate 52', 'weekly', 'delaycompress', 'compress', 'missingok', 'notifempty' ],
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

  package { ['xfsprogs', 'python-requests']:
    ensure => installed,
  }

  file { '/var/cache/swift':
    owner   => swift,
    group   => swift,
    mode    => '0600',
    recurse => true,
  }

  file { '/etc/swift/drive-audit.conf':
    owner   => swift,
    group   => swift,
    content => template('swift/drive-audit.conf.erb')
  }

  cron { 'drive-audit':
    ensure  => present,
    command => 'swift-drive-audit /etc/swift/drive-audit.conf',
    user    => 'swift',
    minute  => 0,
    require => File['/etc/swift/drive-audit.conf'],
  }


  if $multi_daemon_config == false {

    cron { 'swift-recon':
      ensure  => present,
      command => '/usr/bin/swift-recon-cron /etc/swift/object-server.conf',
      user    => 'swift',
      minute  => 5,
      require => File['/etc/swift/object-server.conf'],
    }


  } else {

    cron { 'swift-recon':
      ensure  => present,
      command => '/usr/bin/swift-recon-cron /etc/swift/object-server/1.conf',
      user    => 'swift',
      minute  => 5,
      require => File['/etc/swift/object-server/1.conf'],
    }

  }

  file { '/etc/sysctl.d/60-swift.conf':
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('swift/60-swift-sysctl.conf.erb'),
    notify  => Exec['sysctl-swift'],
  }

  file { '/usr/local/lib/nagios/plugins/check_replication_time':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0775',
    source => 'puppet:///modules/swift/check_replication_time',
  }

  exec { 'sysctl-swift':
    command => '/sbin/sysctl -p /etc/sysctl.d/60-swift.conf',
    unless  => "/usr/bin/test `sysctl -e -n net.nf_conntrack_max` -eq $max_connections",
  }

  $stg_hosts = hiera('firewall::swift_storage_hosts', [])
  nectar::firewall::multisource {[ prefix($stg_hosts, '100 swift-node,') ]:
    proto  => 'tcp',
    dport  => [873, 6000, 6001, 6002],
    action => accept,
  }

  if $multi_daemon_config == true {
    $rep_hosts = hiera('firewall::swift_rep_hosts', [])
    nectar::firewall::multisource {[ prefix($rep_hosts, '101 swift-node-rep,') ]:
      proto  => 'tcp',
      dport  => [873, 6010, 6011, 6012],
      action => accept,
    }
  }

  include swift::object
  include swift::container
  include swift::account

}
