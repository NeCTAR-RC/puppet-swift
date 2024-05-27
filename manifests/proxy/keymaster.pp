#
# Configure Swift Keymaster middleware.
#
# == Examples
#
#  include swift::proxy::keymaster
#
# == Parameters
#
# [*encryption_root_secret*]
# Encryption root secret value.
#
# [*keymaster_config_path*]
# Sets the path from which the keymaster config options should be read
#
class swift::proxy::keymaster (
  $encryption_root_secret,
  $keymaster_config_path   = '/etc/swift/keymaster.conf',
) {

  include swift::deps

  swift_proxy_config {
    'filter:keymaster/use':                   value => 'egg:swift#keymaster';
    'filter:keymaster/keymaster_config_path': value => $keymaster_config_path;
  }

  swift_keymaster_config {
    'keymaster/encryption_root_secret': value => $encryption_root_secret;
  }

}

