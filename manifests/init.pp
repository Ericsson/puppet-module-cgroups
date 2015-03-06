# == Class: cgroups
#
class cgroups (
  $config_file_path = '/etc/cgconfig.conf',
  $service_name     = 'cgconfig',
  $package_name     = 'USE_DEFAULTS',
  $cgconfig_mount   = 'USE_DEFAULTS',
  $cgconfig_content = undef,
  $user_path_fix    = false,
) {

  validate_absolute_path($config_file_path)

  if !is_string($service_name) {
    fail('cgroups::service_name must be a string.')
  }

  if !is_string($package_name) and !is_array($package_name) {
    fail('cgroups::package_name must be a string or an array.')
  }

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '6': {
          $default_package_name   = 'libcgroup'
          $default_cgconfig_mount = '/cgroup'
        }
        default: {
          fail('cgroups is only supported on EL 6.')
        }
      }
    }
    'Suse': {
      case $::lsbmajdistrelease {
        '11': {
          if versioncmp($::operatingsystemrelease, '11.2') > -1 {
            $default_package_name   = 'libcgroup1'
            $default_cgconfig_mount = '/sys/fs/cgroup'

            if $user_path_fix {
              file { 'cgroups_path_fix':
                ensure  => directory,
                path    => $user_path_fix,
                mode    => '0775',
                require => Service['cgconfig_service'],
              }
            }
          }
          else {
            fail('cgroups is only supported on Suse 11.2 and up.')
          }
        }
        default: {
          fail('cgroups is only supported on Suse 11.2 and up.')
        }
      }
    }
    default: {
      fail('cgroups is not supported on this platform.')
    }
  }

  if $package_name == 'USE_DEFAULTS' {
    $package_name_real = $default_package_name
  } else {
    $package_name_real = $package_name
  }

  if $cgconfig_mount == 'USE_DEFAULTS' {
    $cgconfig_mount_real = $default_cgconfig_mount
  } else {
    $cgconfig_mount_real = $cgconfig_mount
  }
  validate_absolute_path($cgconfig_mount_real)

  package { $package_name_real:
    ensure => present,
  }

  file { 'cg_conf':
    ensure  => file,
    notify  => Service['cgconfig_service'],
    path    => $config_file_path,
    content => template('cgroups/cgroup.conf.erb'),
    require => Package[$package_name_real],
  }

  service { 'cgconfig_service':
    ensure  => running,
    enable  => true,
    name    => $service_name,
    require => Package[$package_name_real],
  }
}
