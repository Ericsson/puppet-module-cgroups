# == Class: cgroups

class cgroups (
  $config_file_path = '/etc/cgconfig.conf',
  $service_name     = 'cgconfig',
  $package_name     = 'USE_DEFAULTS',
  $cgconfig_mount   = 'USE_DEFAULTS',
  $cgconfig_content = undef,
  $user_path_fix    = false,
) {

  validate_string($cgconfig_content)
  validate_string($service_name)

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '6': {
          $default_package_name   = 'libcgroup'
          $default_cgconfig_mount = '/cgroup'
        }
        default: {
          fail('cgroups is only supported on RHEL 6')
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
              validate_absolute_path($user_path_fix)
              file { 'path_fix':
                ensure  => directory,
                path    => $user_path_fix,
                mode    => '0775',
                require => Service['cgconfig_service'],
              }
            }
          }
          else {
            fail('cgroups is only supported on Suse 11.2 and upward')
          }
        }
        default: {
          fail('cgroups is only supported on Suse 11 (11.2 and up')
        }
      }
    }
    default: {
      fail('cgroups is not supported on this platform')
    }
  }

  if $package_name == 'USE_DEFAULTS' {
    $real_package_name = $default_package_name
  } else {
    $real_package_name = $package_name
  }

  if $cgconfig_mount == 'USE_DEFAULTS' {
    $real_cgconfig_mount = $default_cgconfig_mount
  } else {
    $real_cgconfig_mount = $cgconfig_mount
  }

  validate_string($real_package_name)

  validate_string($real_cgconfig_mount)

  package { $real_package_name:
    ensure => present,
  }

  file { 'cg_conf':
    ensure  => file,
    notify  => Service['cgconfig_service'],
    path    => $config_file_path,
    content => template('cgroups/cgroup.conf.erb'),
    require => Package[$real_package_name],
  }

  service { 'cgconfig_service':
    ensure  => running,
    enable  => true,
    name    => $service_name,
    require => Package[$real_package_name],
  }
}
