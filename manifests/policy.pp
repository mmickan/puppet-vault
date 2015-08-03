#
# == Define: vault::policy
#
# Create a Vault policy.  The policy will be written to disk under
# /etc/vault/policies and written to Vault.
#
# === Parameters
#
# [*name*]
#   String. The name of the policy to deploy.  This will be used as the base
#   of the filename in /etc/vault/policies and as the name of the policy in
#   Vault.  Defaults to the name of the resource.
#
# [*token*]
#   String.  Authentication token to authenticate to Vault.  If not
#   provided, the helper script will attempt to log in using
#   $vault::puppet_app_id as the app_id - if Vault has been bootstrapped
#   by the vault puppet module, you shouldn't need to provide a token.
#
# [*addr*]
#   String.  The address of the Vault instance to connect to.
#   Default: https://127.0.0.1:8200
#
# [*policy*]
#   Hash.  A mapping of paths to policies.  Required.
#
# === Example usage
#
#  vault::policy { 'mypolicy':
#    policy => {
#      'sys/*'               => 'deny',
#      'secret/*'            => 'write',
#      'secret/foo'          => 'read',
#      'secret/super-secret' => 'deny',
#  }
#
define vault::policy(
  $policy,
  $token  = undef,
  $addr   = 'https://127.0.0.1:8200',
) {

  ensure_resource('file', '/etc/vault/policies', {
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  })

  file { "/etc/vault/policies/${name}.hcl":
    content => template('vault/policy.hcl.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  if $token {
    $_auth = "--token=${token}"
  } else {
    $_auth = "--app-id=${vault::puppet_app_id}"
  }

  exec { "vault policy-write ${name}":
    command     => "vault-policy ${_auth} --addr=${addr} -- ${name}",
    path        => "/usr/local/bin:${::path}",
    refreshonly => true,
    subscribe   => File["/etc/vault/policies/${name}.hcl"],
    require     => File["/etc/vault/policies/${name}.hcl"],
  }

}
