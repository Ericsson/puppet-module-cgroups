puppet-module-cgroups
===

Puppet module to manage cgroups.

The module installs and configures cgroups on servers.

# Compatability #

This module has been tested on puppet v 2.7 and v3

  * EL 6
  * SLED 11 sp2

# Parameters #

config_file_path
---------
Path to cgroups config file.

- *Default*: '/etc/cgconfig.conf'

service_name
---------
name of service.

- *Default*: 'cgconfig'

package_name
---------
name of package that enables cgroups.

- *RedHat*: 'libcgroup'
- *Suse*: 'libcgroup1'

cgconfig_mount
--------
where cgroups is mounted

- *RedHat*: '/cgroup'
- *Suse*: '/sys/fs/cgroup'

cgconfig_content
--------
The content of the cgroup file, this is a required option.

- *Default*: undef

user_path_fix
--------
A path to set 0777 permissions on. This is a fix for Suse that have a bug in setting this though the config file.

- *Default*: ''

# example with suse 11.2 bugfix for permissions#

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
    }
    cpu {
    }
  }
</pre>
