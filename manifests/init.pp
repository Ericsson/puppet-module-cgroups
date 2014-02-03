# == Class: cgroups
#
# Full description of class cgroups here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { cgroups:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <martin.quensel@bolero.se>
#
# === Copyright
#
# Copyright 2014 Martin Quensel, unless otherwise noted.
#
# group user/mgw-all {
#   perm {
#     task {
#       uid = root;
#       gid = mgw-all;
#     } admin {
#       uid = root;
#       gid = mgw-all;
#     }
#   } cpu {
#   }
# }

class cgroups (
  $config_file_path = '/etc/cgconfig.conf',
  $service_name     = 'cgconfig',
  $package_name     = 'DEFAULT',
  $cgconfig_mount   = 'DEFAULT',
  $cgconfig_content = [],
  $user_path_fix    = undef,
  ) {

  case $::osfamily {
    'RedHat': {
      $default_package_name = 'libcgroup'
      $default_cgconfig_mount   = '/cgroup'
    }
    'Suse': {
      if $::operatingsystemrelease == '11.2' {
        $default_package_name = 'libcgroup1'
        $default_cgconfig_mount = '/sys/fs/cgroup'
        if $user_path_fix {
          file { "$user_path_fix":
            ensure => directory,
            mode   => 0777,
            require => Service['cgconfig_service'],
          }
        } else {
          fail('cgroups on suse 11,2 needs user_path_fix argument')
        }
      }
      else {
        fail('cgroups is only supp on Suse 11.2')
      }
    }
    default: {
      fail( "cgroups is not supported on this platform")
    }
  }

  if $package_name == 'DEFAULT' {
    $real_package_name = $default_package_name
  } else {
    $real_package_name = $package_name
  }

  if $cgconfig_mount == 'DEFAULT' {
    $real_cgconfig_mount = $default_cgconfig_mount
  } else {
    $real_cgconfig_mount = $cgconfig_mount
  }

  package { 'cg_package':
    ensure   => installed,
    name => $real_package_name,
  }

  file { 'cg_conf':
    ensure  => file,
    notify  => Service["cgconfig_service"],
    path    => $config_file_path,
    content => template('cgroups/cgroup.conf.erb'),
    require => Package['cg_package'],
  }

  service { 'cgconfig_service':
    ensure  => running,
    enable  => true,
    name   => $service_name,
    require => Package['cg_package'],
  }

}
