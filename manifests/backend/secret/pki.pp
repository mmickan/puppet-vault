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
  $addr  = 'https://127.0.0.1:8200',
) {

  include ::vault::tools

  if $token {
    $_auth = "--token=${token}"
  } else {
    $_auth = "--app-id=${vault::puppet_app_id}"
  }

  exec { "vault-secret-pki ${name}":
    command => "vault-secret-pki ${_auth} -- ${name}",
    unless  => "vault-check-mount ${_auth} -- pki-${name}",
    path    => "/usr/local/bin:${::path}",
  }

}
