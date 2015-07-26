#
# == Class: vault::debug
#
# Write all variables to a file to allow them to be inspected for debugging
# this module.
#
# === Example usage
#
# This class is autoloaded if vault::debug is set to true.
#
class vault::debug {

  ensure_resource('file', $vault::debug_dir, {
    ensure => 'directory',
  })

  file { "${vault::debug_dir}/vault":
    ensure  => present,
    content => template('vault/debug_variables.erb'),
    mode    => '0400',
    owner   => 'root',
    group   => 'root',
  }

}
