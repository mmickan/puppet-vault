#
# == Class: vault::service
#
# Service management for vault
#
# === Example usage
#
# This class is not called directly.
#
class vault::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $vault::manage_service {
    service { 'vault':
      ensure  => 'running',
      enable  => true,
      restart => '/bin/echo "Vault requires a restart"',
    }
  }

}
