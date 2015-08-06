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

  service { 'vault':
    ensure  => 'running',
    enable  => true,
    restart => '/bin/echo -e "Vault requires a restart.\nThis will seal the Vault and it cannot be unsealed by Puppet.\nPlease perform the restart and unseal manually."',
  }

}
