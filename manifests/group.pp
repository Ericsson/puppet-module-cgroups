define cgroups::group (
  $permissions = {},
  $controllers = {},
  $target      = undef,
) {



  validate_hash($permissions)
  validate_hash($controllers)

  include ::cgroups
  
  if $target {
    $target_real = $target
  } else {
    $target_real = "${::cgroups::config_d_path}/${name}.conf"
  }

  validate_absolute_path($target_real)

  file { $target_real:
    ensure  => file,
    content => template('cgroups/group.conf.erb'),
    notify  => Service[$cgroups::service_name],
  }

}

