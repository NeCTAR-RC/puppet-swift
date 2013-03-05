puppet-swift
============

Variables
---------

 * swift::keystone_user
 * swift::keystone_password
 * swift::protocol
 * swift::memcached_servers
 * swift::swift_hash

Openstack

 * openstack_version

Keystone

 * keystone::service_tenant
 * keystone::host
 * keystone::protocol


Classes
-------
for a swift proxy:

include swift::proxy

for a swift storage node

include swift::node


SSL frontend
------------
If you set swift_protocol to https swift proxy will run on port 8889 and listen on localhost
Then it is up to you to set up the ssl proxy. See the nginx module for that