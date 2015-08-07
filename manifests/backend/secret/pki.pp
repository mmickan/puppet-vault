#
# == Define: vault::backend::secret::pki
#
# Configure Vault's PKI secret backend.
#
# === Parameters
#
# [*name*]
#   String.  The domain this PKI backend is for.  This will be used as part
#   of the mount point for this instance of the PKI backend.  It will also
#   be the domain under which certificates can be issued.
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
#  vault::backend::secret::pki { 'example.com': }
#
define vault::backend::secret::pki(
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

  # TODO: exit without error if vault is sealed (good for HA vault where
  # only the primary is unsealed during the initial puppet run?)
  exec { "authorise puppet to configure PKI secret backend for ${name}":
    command => "vault-auth-app --addr=https://${::vault::advertise_addr}:8200 --app-id=${::vault::puppet_app_id} -- puppet ${::vault::puppet_app_id} configure-pki-${name}",
    unless  => "vault-auth-app --check --addr=https://${::vault::advertise_addr}:8200 --app-id=${::vault::puppet_app_id} -- puppet ${::vault::puppet_app_id} configure-pki-${name}",
    path    => "/usr/local/bin:${::path}",
    require => [
      File['/usr/local/bin/vault-auth-app'],
      Exec['vault-bootstrap'],
    ],
  }
  -> vault::policy { "configure-pki-${name}":
    policy => {
      "pki-${name}/config/ca" => 'sudo',
      'secret/ssl/*'          => 'read',
      "pki-${name}/*"         => 'write',
    }
  }
  -> exec { "mount PKI secret backend for ${name}":
    command => "vault-secret-pki --addr=${addr} ${_auth} -- ${name}",
    unless  => "vault-check-mount --addr=${addr} ${_auth} -- pki-${name}",
    path    => "${::vault::bin_dir}:${::path}",
  }
  -> Vault::Ssl_certificate <| domain == $name |>

  exec { "authorise deploy-ssl-certificate app for ${name}":
    command => "vault-auth-app --addr=https://${::vault::advertise_addr}:8200 --app-id=${::vault::puppet_app_id} --enable-backend -- deploy-ssl-certificate @deploy-ssl-certificate deploy-ssl-certificate-${name}",
    unless  => "vault-auth-app --check --addr=https://${::vault::advertise_addr}:8200 --app-id=${::vault::puppet_app_id} --enable-backend -- deploy-ssl-certificate @deploy-ssl-certificate deploy-ssl-certificate-${name}",
    path    => "/usr/local/bin:${::path}",
    require => [
      File['/usr/local/bin/deploy-ssl-certificate'],
      File['/usr/local/bin/vault-auth-app'],
      Exec['vault-bootstrap'],
    ],
  }
  -> vault::policy { "deploy-ssl-certificate-${name}":
    policy => { "pki-${name}/issue/consul" => 'write' }
  }
  -> Vault::Ssl_certificate <| domain == $name |>

}
