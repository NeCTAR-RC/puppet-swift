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
class swift::proxy::keymaster (
  $encryption_root_secret,
) {

  include swift::deps

  swift_proxy_config {
    'filter:keymaster/use':                    value => 'egg:swift#keymaster';
    'filter:keymaster/encryption_root_secret': value => $encryption_root_secret, secret => true;
  }

  # NOTE(jake): removes old values in Nectar version that did not make upstream
  swift_proxy_config {
    'filter:keymaster/keymaster_config_path': value => $facts['os_service_default'];
  }

  swift_keymaster_config {
    'keymaster/encryption_root_secret': value => $facts['os_service_default'];
  }

}
