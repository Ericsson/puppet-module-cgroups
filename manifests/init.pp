# == Class: cgroups

class cgroups (
  $config_file_path = '/etc/cgconfig.conf',
  $service_name     = 'cgconfig',
  $package_name     = 'DEFAULT',
  $cgconfig_mount   = 'DEFAULT',
  $cgconfig_content = undef,
  $user_path_fix    = undef,
) {

  validate_array($cgconfig_content)

  case $::osfamily {
    'RedHat': {
      $default_package_name   = 'libcgroup'
      $default_cgconfig_mount = '/cgroup'
    }
    'Suse': {
      if $::operatingsystemrelease == '11.2' {

        $default_package_name   = 'libcgroup1'
        $default_cgconfig_mount = '/sys/fs/cgroup'

        if $user_path_fix {
          file { 'path_fix':
            ensure  => directory,
            path    => $user_path_fix,
            mode    => '0777',
            require => Service['cgconfig_service'],
          }
        }
      }
      else {
        fail('cgroups is only supported on Suse 11.2')
      }
    }
    default: {
      fail('cgroups is not supported on this platform')
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

  package { $real_package_name:
    ensure => installed,
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
