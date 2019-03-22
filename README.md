# puppet-module-cgroups

Manage cgroups configuration service and files.

- /etc/cgconfig.conf
- /etc/cgconfig.d/*.conf

## Compatibility

This module has been tested to work on the following systems with Puppet v3
(with and without the future parser) and Puppet v4 (with strict variables)
using Ruby versions 1.8.7 (Puppet v3 only), 1.9.3, 2.0.0, 2.1.0 and 2.3.1.

- EL 6
- EL 7
- SLED 11 SP2
- SLES 11 SP2

[![Build Status](https://travis-ci.org/Ericsson/puppet-module-cgroups.png?branch=master)](https://travis-ci.org/Ericsson/puppet-module-cgroups)

## Class `cgroups`

### Description

The `cgroups` class is used to configure the cgroup service and its main configuration details.

### Parameters

---

#### cgconfig_content (string)

Optional, specify arbitary content for the cgconfig.conf file that will be included at the bottom.

- *Default*: undef

---

#### config_file_path (string)

Absolute path to cgroups config file.

- *Default*: '/etc/cgconfig.conf'

---

#### groups (hash)

A hash containing group resources to be configured (see below for cgroups::group resources)

- *Default*: undef

##### Example

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

##### Hiera example with Suse 11.2 bugfix

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

---

#### mounts (hash)

A hash containing mounts to be configured in /etc/cgconfig.conf.
NOTE: On systemd managed systems, the default resource controllers are the domain of systemd, therefore this setting should probably not be used unless you are managing a controller not yet supported by systemd such as net_prio.

- *Default*: undef

##### Example

```yaml
cgroups::mounts:
  cpu: '/cgroup'
```

---

#### package_name (string or array)

Name of package(s) that enables cgroups. Only set it to overwrite the modules defaults: RedHat 'libcgroup', Suse 'libcgroup1'.

- *Default*: undef

---

#### service_name (string)

Name of service to manage.

- *Default*: 'cgconfig'

---

#### user_path_fix (string)

Absolute path to set 0775 permissions on when defined. This is a fix for Suse that have a bug in setting this though the config file. Only available on Suse.

- *Default*: undef

---

#### rules_file_path (string)

Absolute path to cgroups rules config file.

- *Default*: '/etc/cgrules.conf'

---

#### rules_service_name (string)

Name of the rules service to manage.

- *Default*: 'cgred'

---

#### rules_service_enable (boolean)

A boolean to decide whether the rules service should be enabled or not.

- *Default*: false

---

#### rules_service_ensure (string)

The state that shoudl be enforced for the rules service.

- *Default*: 'stopped'

---

#### rules (hash)

An optional hash containing rules for the `cgrules.conf` file.  Note that the keys of the hash are the `user` values (one per line in the configuration file), and the `controllers` and `destination` elements of the next level of each hash are required.

- *Default*: undef

##### rules Example

```puppet
  rules => {
    '@template1' => {
      controllers => 'cpu,cpuacct,memory',
      destination => 'template1/%u',
    },
    '@template2'   => {
      controllers => 'cpu,cpuacct,memory',
      destination => 'template2/%u',
    },
  },
```

##### Hiera rules example

```yaml
cgroups::rules:
  '@template1':
    controllers: 'cpu,cpuacct,memory'
    destination: 'template1/%u'
  '@template2':
    controllers: 'cpu,cpuacct,memory'
    destination: 'template2/%u'
```

---

## Defined type `cgroups::group`

### Description

The `cgroups::group` definition is used to configure cgroup entries in /etc/cgconfig.d.

You can also specify `cgroups::groups` from hiera as a hash of group resources and they will be created by the base class using create_resources.

### Parameters

---

#### controllers (hash)

An optional hash containing the controllers for the group.

- *Default*: undef

##### Example

```puppet
  controllers => {
    'cpuset' => {
      'cpuset.mems' => '0',
      'cpuset.cpus' => '0,1'
    }
  }
```

---

#### permissions (hash)

An optional hash containing permissions for the group.

- *Default*: undef

##### Example

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

---

#### target_path (string)

Optional parameter to define in which path the configuration file should be put. By default the module will use the /etc/cgconfig.d directory.

- *Default*: '/etc/cgconfig.d'

---

### Full example

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

---
