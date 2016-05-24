puppet-module-cgroups
===

Puppet module to manage cgroups.

[![Build Status](https://travis-ci.org/Ericsson/puppet-module-cgroups.png?branch=master)](https://travis-ci.org/Ericsson/puppet-module-cgroups)

# Compatibility

This module has been tested to work on the following systems with Puppet v3
(with and without the future parser) and Puppet v4 (with strict variables)
using Ruby versions 1.8.7 (Puppet v3 only), 1.9.3, 2.0.0 and 2.1.0.

  * EL 6
  * SLED 11 SP2

# Parameters

config_file_path
----------------
Path to cgroups config file.

- *Default*: '/etc/cgconfig.conf'

service_name
------------
name of service.

- *Default*: 'cgconfig'

package_name
------------
name of package that enables cgroups.

- *RedHat*: 'libcgroup'
- *Suse*: 'libcgroup1'

cgconfig_mount
--------------
where cgroups is mounted

- *RedHat*: '/cgroup'
- *Suse*: '/sys/fs/cgroup'

cgconfig_content
----------------
The content of the cgroup file, this is a required option.

- *Default*: undef

user_path_fix
-------------
A path to set 0777 permissions on. This is a fix for Suse that have a bug in setting this though the config file.

- *Default*: ''

# Heira example with Suse 11.2 bugfix

<pre>
cgroups::user_path_fix: '/sys/fs/cgroup/user/mgw-all'
cgroups::cgconfig_content: |
  group user/mgw-all {
   perm {
    task {
      uid = root;
      gid = mgw-all;
    } admin {
      uid = root;
      gid = mgw-all;
    }
   } cpu {
   }
  }
</pre>
