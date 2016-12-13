# Nagios checks for swift proxy
class swift::proxy::nagios_checks {
  # These are checks that can be run by the nagios server.
  nagios::command {
    'check_swift_ssl':
      check_command => '/usr/lib/nagios/plugins/check_http --ssl -u /healthcheck -p \'$ARG1$\' -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
    'check_swift':
      check_command => '/usr/lib/nagios/plugins/check_http -u /healthcheck -p \'$ARG1$\' -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
    'check_swift_internal':
      check_command => '/usr/lib/nagios/plugins/check_http -p \'$ARG1$\' -e 400 -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
    'check_swift_internal_ip':
      check_command => '/usr/lib/nagios/plugins/check_http -p \'$ARG1$\' -e 400,405 -H \'$HOSTADDRESS$\' -I \'$ARG2$\'';
    'check_swift_operations':
      check_command => '/usr/local/lib/nagios/plugins/check_swift -A \'$ARG1$\' -U \'$ARG2$\' -P \'$ARG3$\' -T \'$ARG4$\' -R \'$ARG5$\' -c nagios';
  }

  file { '/usr/local/lib/nagios/plugins/check_swift':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0775',
    source => 'puppet:///modules/swift/check_swift',
  }
}
