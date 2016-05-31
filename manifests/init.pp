# == Class: cgroups
#
class cgroups (
  $config_file_path = '/etc/cgconfig.conf',
  $service_name     = 'cgconfig',
  $package_name     = undef,
  $cgconfig_content = undef,
  $user_path_fix    = false,
  $mounts           = {},
  $groups           = {},
) {

  validate_absolute_path($config_file_path)

  if type3x($service_name) != 'string' {
    fail('cgroups::service_name must be a string.')
  }

  if type3x($package_name) != 'string' and type3x($package_name) != 'array' {
    fail('cgroups::package_name must be a string or an array.')
  }

  validate_hash($mounts)
  validate_hash($groups)


  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '6','7': {
          $default_package_name   = 'libcgroup'
        }
        default: {
          fail('cgroups is only supported on EL 6 and 7.')
        }
      }
    }
    'Suse': {
      case $::operatingsystemrelease {
        /11\.\d/: {
          if versioncmp($::operatingsystemrelease, '11.2') > -1 {
            $default_package_name   = 'libcgroup1'

            if $user_path_fix {
              file { 'cgroups_path_fix':
                ensure  => directory,
                path    => $user_path_fix,
                mode    => '0775',
                require => Service[$service_name],
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

  $package_name_real = $package_name ? {
    undef   => $default_package_name,
    default => $package_name,
  }


  create_resources('cgroups::group', $groups)

  package { $package_name_real:
    ensure => present,
  }

  file { $config_file_path:
    ensure  => file,
    notify  => Service[$service_name],
    content => template('cgroups/cgroup.conf.erb'),
    require => Package[$package_name_real],
  }

  service { $service_name:
    ensure  => running,
    enable  => true,
    require => Package[$package_name_real],
  }
}
