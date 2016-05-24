puppet-module-cgroups
===

Puppet module to manage cgroups.

[![Build Status](https://travis-ci.org/Ericsson/puppet-module-cgroups.png?branch=master)](https://travis-ci.org/Ericsson/puppet-module-cgroups)

# Compatability

This module has been tested to work on the following systems with Puppet v3
(with and without the future parser) and Puppet v4 with Ruby versions 1.8.7,
1.9.3, 2.0.0 and 2.1.0.

  * EL 6
  * EL 7
  * SLED 11 SP2

# cgroup class

## Parameters

config_file_path
----------------
Path to cgroups config file.

- *Default*: '/etc/cgconfig.conf'

config_d_path
-------------
Path to the .d configuration directory

- *Default*: '/etc/cgconfig.d'


service_name
------------
name of service.

- *Default*: 'cgconfig'

package_name
------------
name of package that enables cgroups.

- *RedHat*: 'libcgroup'
- *Suse*: 'libcgroup1'

groups
------
A hash containing group resources to be configured (see below for cgroups::group resources)

Eg:
```yaml
cgroups::groups:
  "user/mgw-all":
    permissions:
      task:
        uid: root
        gid: mgw-all
      admin:
        uid: root
        gid: mgw-all
    controllers:
      cpuset:
        "cpuset.mems": "0"
        "cpuset.cpus": "0,1"
```

mounts
------
A hash containing mounts to be configured in /etc/cgconfig.conf

Eg:
```yaml
cgroups::mounts:
  cpu: /cgroup
```

NOTE: As of RedHat 7 default resource controllers are the domain of systemd therefore this setting should probably not be used unless you are managing a controller not yet supported by systemd such as net_prio


cgconfig_content
----------------
Optional, specify arbitary content for the cgconfig.conf file

- *Default*: undef

user_path_fix
-------------
A path to set 0777 permissions on. This is a fix for Suse that have a bug in setting this though the config file.

- *Default*: ''

# Heira example with Suse 11.2 bugfix

```yaml
cgroups::user_path_fix: '/sys/fs/cgroup/user/mgw-all'
cgroups::groups:
  "user/mgw-all":
    permissions:
      task:
        uid: root
        gid: mgw-all
      admin:
        uid: root
        gid: mgw-all
    controllers:
      cpuset:
        "cpuset.mems": "0"
        "cpuset.cpus": "0,1"
```

# cgroups::group defined type

## Description

The `cgroups::group` definition is used to configure cgroup entries in /etc/cgconfig.d.  

## Parameters

permissions
-----------

An optional hash containing permissions for the group.

Eg
```puppet
  permissions => {
    'task' => {
      'uid' => 'root',
      'gid' => 'mgw-all',
    },
    'admin' => {
      'uid' => 'root',
      'gid' => 'mgw-all',
    },
  }
```

controllers
-----------

A hash containing the controllers for the group

Eg
```puppet
  controllers => {
    'cpuset' => { 
      'cpuset.mems' => '0',
      'cpuset.cpus' => '0,1'
    }
  }
```

target
------

Optional parameter to define where the configuration should be put.  By default the module will use the /etc/cgconfig.d directory

## Full example

```puppet
cggroups::group { 'mgw/user':
  permissions => {
    'task' => {
      'uid' => 'root',
      'gid' => 'mgw-all',
    },
    'admin' => {
      'uid' => 'root',
      'gid' => 'mgw-all',
    },
  },
  controllers => {
    'cpuset' => { 
      'cpuset.mems' => '0',
      'cpuset.cpus' => '0,1'
    }
  }
}
```

You can also specify `cgroups::groups` from hiera as a hash of group resources and they will be created by the base class using create_resources


