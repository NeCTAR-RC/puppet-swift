# == Class: swift::client
#
# Installs swift client.
#
# === Parameters
#
# [*ensure*]
#   (optional) Ensure state of the package.
#   Defaults to 'present'.
#
class swift::client (
  $ensure = 'present',
) {

  package { 'python-swiftclient':
    ensure => $ensure,
    tag    => ['openstack','swift-support-package']
  }

}
