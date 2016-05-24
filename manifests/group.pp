define cgroups::group (
  $permissions = {},
  $controllers = {},
  $target      = undef,
) {



  include ::cgroups
  
  if $target {
    $target_real = $target
  } else {
    $target_real = "${::cgroups::config_d_path}/${name}.conf"
  }

  file { $target_real:
    ensure  => file,
    content => template('cgroups/group.conf.erb'),
    notify  => Service[$cgroups::service_name],
  }

}

