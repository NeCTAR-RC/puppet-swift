puppet-swift
============

Variables
---------

 * ipaddress
 * swift_hash
 * swift_keystone_password
 * swift_keystone_user
 * swift_memcached_servers
 * swift_protocol
 * total_procs 
 * workers 

Openstack

 * openstack_version

Keystone

 * keystone_host
 * keystone_protocol
 * keystone_service_tenant

Nagios

 * nagios_keystone_pass 
 * nagios_keystone_tenant 
 * nagios_keystone_user 

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
