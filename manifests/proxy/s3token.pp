# == Class: swift::proxy::s3token
#
# Configure swift s3token.
#
# === Parameters
#
# [*auth_host*]
#   (optional) The keystone host
#   Defaults to undef.
#
# [*auth_port*]
#   (optional) The Keystone client API port
#   Defaults to undef.
#
# [*auth_protocol*]
#   (optional) http or https
#    Defaults to undef.
#
# [*auth_uri*]
#   (optional) The Keystone server uri
#   Defaults to http://127.0.0.1:5000
#
# [*reseller_prefix*]
#   Prefix that will be prepended to the project to
#   form the account
#   Default to 'AUTH_'
#
# [*delay_auth_decision*]
#   Enable downstream WSGI components to decide the
#   validation of s3-style requests.
#   Default to False
#
# [*http_timeout*]
#   Connection timeout to be used during communicating
#   with Keystone
#   Default to $::os_service_default
#
# [*secret_cache_duration*]
#   The number of seconds that secrets can be cached.
#   Set this to some number greater than zero to enable
#   caching, which will help to reduce latency for the
#   client and load on Keystone.
#   Default to 0
#
# [*auth_url*]
#   (Optional) Keystone credentials used for secret caching
#   The URL to use for authentication.
#   Defaults to 'http://127.0.0.1:5000'
#
# [*auth_type*]
#   (Optional) Keystone credentials used for secret caching
#   The plugin for authentication
#   Defaults to password
#
# [*username*]
#   (Optional) Keystone credentials used for secret caching
#   The name of the service user
#   Defaults to swift
#
# [*password*]
#   (Optional) Keystone credentials used for secret caching
#   The password for the user
#   Defaults to password
#
# [*project_name*]
#   (Optional) Keystone credentials used for secret caching
#   Service project name
#   Defaults to services
#
# [*project_domain_id*]
#   (Optional) Keystone credentials used for secret caching
#   id of domain for $project_name
#   Defaults to default
#
# [*user_domain_id*]
#   (Optional) Keystone credentials used for secret caching
#   id of domain for $username
#   Defaults to default
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::s3token(
  $auth_host             = undef,
  $auth_port             = undef,
  $auth_protocol         = undef,
  $auth_uri              = 'http://127.0.0.1:5000',
  $reseller_prefix       = 'AUTH_',
  $delay_auth_decision   = false,
  $http_timeout          = $::os_service_default,
  $secret_cache_duration = 0,
  $auth_url              = 'http://127.0.0.1:5000',
  $auth_type             = 'password',
  $username              = 'swift',
  $password              = 'password',
  $project_name          = 'services',
  $project_domain_id     = 'default',
  $user_domain_id        = 'default'
) {

  include ::swift::deps

  if $auth_host and $auth_port and $auth_protocol {
    warning('Use of the auth_host, auth_port, and auth_protocol options have been deprecated in favor of auth_uri.')
    $auth_uri_real = "${auth_protocol}://${auth_host}:${auth_port}"
  } else {
    $auth_uri_real = $auth_uri
  }


  swift_proxy_config {
    'filter:s3token/use':                   value => 'egg:swift#s3token';
    'filter:s3token/auth_uri':              value => $auth_uri_real;
    'filter:s3token/reseller_prefix':       value => $reseller_prefix;
    'filter:s3token/delay_auth_decision':   value => $delay_auth_decision;
    'filter:s3token/http_timeout':          value => $http_timeout;
    'filter:s3token/secret_cache_duration': value => $secret_cache_duration;
    'filter:s3token/auth_url':              value => $auth_url;
    'filter:s3token/auth_type':             value => $auth_type;
    'filter:s3token/username':              value => $username;
    'filter:s3token/password':              value => $password;
    'filter:s3token/project_name':          value => $project_name;
    'filter:s3token/project_domain_id':     value => $project_domain_id;
    'filter:s3token/user_domain_id':        value => $user_domain_id;
  }
}
