# == Define: cgroups::group
#
# Manage cgroup entries in /etc/cgconfig.d
#
define cgroups::group (
  $permissions = {},
  $controllers = {},
  $target_path = '/etc/cgconfig.d',
) {

  # variables preparation
  $fscompat_name = regsubst($name, '\/', '-')
  $target = "${target_path}/${fscompat_name}.conf"

  # variables validation
  validate_hash($permissions)
  validate_hash($controllers)
  validate_absolute_path($target)

  # functionality
  include ::cgroups

  file { $target:
    ensure  => file,
    content => template('cgroups/group.conf.erb'),
    notify  => [
      Service[$cgroups::service_name],
      Service[$cgroups::rules_service_name],
    ],
  }
}
