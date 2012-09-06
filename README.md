puppet-swift
============

Variables
---------

 * swift_keystone_user
 * swift_keystone_password
 * swift_protocol
 * swift_memcached_servers
 * swift_hash

Openstack

 * openstack_version

Keystone

 * keystone_service_tenant
 * keystone_host
 * keystone_protocol


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