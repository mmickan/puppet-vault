#
# == Define: vault::backend::secret::ssh
#
# Configure Vault's SSH secret backend.
#
# === Parameters
#
# [*name*]
#   String.  The mount point for this backend - should usually be 'ssh'
#   unless there's a need for multiple ssh backends.
#
# [*token*]
#   String.  Authentication token to authenticate to Vault.  If not
#   provided, the helper script will attempt to log in using
#   $vault::puppet_app_id as the app_id - if Vault has been bootstrapped by
#   the vault puppet module, you shouldn't need to provide a token.
#
# [*addr*]
#   String.  The address of the Vault instance to connect to.
#   Default: https://127.0.0.1:8200
#
# === Example usage
#
#  vault::backend::secret::ssh { 'ssh': }
#
define vault::backend::secret::ssh(
  $token = undef,
  $addr  = "${::vault::advertise_scheme}://${::vault::advertise_addr}:${::vault::advertise_port}",
) {

  if ! defined(Class['vault']) {
    include vault
  }

  $_auth = $token ? {
    undef   => "--app-id=${vault::puppet_app_id}",
    default => "--token=${token}",
  }

  exec { "mount SSH secret backend at ${name}/":
    command => "vault-secret-ssh --addr=${addr} ${_auth} -- ${name}",
    unless  => "vault-check-mount --addr=${addr} ${_auth} -- ${name}",
    path    => "${::vault::bin_dir}:${::path}",
  }

  exec { "authorise allow-ssh-access app for ${name}":
    command => "vault-auth-app --addr=${addr} --app-id=${::vault::puppet_app_id} --enable-backend -- allow-ssh-access @allow-ssh-access allow-ssh-access-${name}",
    unless  => "vault-auth-app --check --addr=${addr} --app-id=${::vault::puppet_app_id} --enable-backend -- allow-ssh-access @allow-ssh-access allow-ssh-access-${name}",
    path    => "${::vault::bin_dir}:${::path}",
    require => [
      File["${::vault::bin_dir}/allow-ssh-access"],
      File["${::vault::bin_dir}/vault-auth-app"],
      Exec['vault-bootstrap'],
    ],
  }
  -> vault::policy { 'allow-ssh-access':
    policy => {
      "${name}/keys/*"  => 'sudo',
      "${name}/roles/*" => 'write',
    }
  }

  exec { "authorise obtain-ssh-access app for ${name}":
    command => "vault-auth-app --addr=${addr} --app-id=${::vault::puppet_app_id} --enable-backend -- obtain-ssh-access @obtain-ssh-access obtain-ssh-access-${name}",
    unless  => "vault-auth-app --check --addr=${addr} --app-id=${::vault::puppet_app_id} --enable-backend -- obtain-ssh-access @obtain-ssh-access obtain-ssh-access-${name}",
    path    => "${::vault::bin_dir}:${::path}",
    require => [
      File["${::vault::bin_dir}/obtain-ssh-access"],
      File["${::vault::bin_dir}/vault-auth-app"],
      Exec['vault-bootstrap'],
    ],
  }
  -> vault::policy { 'obtain-ssh-access':
    policy => {
      "${name}/creds/*" => 'write',
    }
  }

}
