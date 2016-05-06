#
# == Define: vault::allow_ssh_access
#
# Configure Vault to deploy ssh keys for controlled access to the server
# a resource of this type is applied to.
#
# === Parameters
#
# [*name*]
#   The name variable must be globally unique for the Vault server in use,
#   and is used as the name for both the key and role within Vault.  It's
#   suggested that the FQDN (and potentially port) be used to ensure that
#   uniqueness.
#
# [*admin_user*]
#   String.  The shell account Vault will use to deploy credentials.
#
# [*default_user*]
#   String.  The user to deploy credentials for by default.
#
# [*key_type*]
#   String.  Type of credentials to generate.
#   Valid values: 'otp' or 'dynamic'.
#   Default: 'otp'
#
# [*cidr_list*]
#   Array of strings.  List of CIDR blocks Vault will attempt to provide
#   access to.
#   Default: ["${::ipaddress}/32"]
#
# [*exclude_cidr_list*]
#   Array of strings.  List of CIDR blocks to be excluded from the larger
#   blocks listed in $cidr_list.
#   Default: []
#
# [*port*]
#   Integer.  Port number of service for which credentials are to be
#   generated.
#   Default: 22
#
# [*key_bits*]
#   Integer.  Length of the RSA dynamic key in bits.
#   Valid values: 1024, 2048
#   Default: 1024
#
# [*install_script_source*]
# [*install_script_content*]
#   Install script used to install and uninstall public keys.  Both default
#   to undef, leave both as defaults to use Vault's built in script.  Source
#   vs content uses semantics of Puppet's file resource type.
#
# [*allowed_users*]
#   Array of strings.  List of users that credentials can be generated for.
#   Default: []
#
# [*key_option_specs*]
#   Array of strings.  List of option specificiations that will be prefixed
#   to generated RSA keys.
#   Default: []
#
# [*vault*]
#   String.  Base URL for Vault instance to connect to.
#   Default: based on advertise_scheme, advertise_addr and advertise_port in
#   vault class
#
# === Example usage
#
#  vault::allow_ssh_access { "${::fqdn}_22":
#    admin_user   => 'vaultadmin',
#    default_user => 'jenkins',
#    vault        => 'https://vault.example.com:8200',
#  }
#
define vault::allow_ssh_access(
  $admin_user             = undef,
  $default_user           = undef,
  $key_type               = 'otp',
  $cidr_list              = [ "${::ipaddress}/32" ],
  $exclude_cidr_list      = [],
  $port                   = 22,
  $key_bits               = 1024,
  $install_script_source  = undef,
  $install_script_content = undef,
  $allowed_users          = [],
  $key_option_specs       = [],
  $vault                  = undef,
) {

  if ! defined(Class['vault']) {
    include vault
  }

  $_vault = $vault ? {
    undef   => "${::vault::advertise_scheme}://${::vault::advertise_addr}:${::vault::advertise_port}",
    default => $vault,
  }

  # data validation
  validate_string($admin_user)
  validate_string($default_user)
  validate_re($key_type, '^(otp|dynamic)$', 'key_type must be otp or dynamic')
  validate_array($cidr_list)
  validate_array($exclude_cidr_list)
  validate_integer($port)
  validate_integer($key_bits)
  if $key_bits != 1024 and $key_bits != 2048 {
    fail('key_bits must be 1024 or 2048')
  }
  if $install_script_source { validate_string($install_script_source) }
  if $install_script_content { validate_string($install_script_content) }
  if $install_script_source and $install_script_content {
    fail('only source OR content can be specified for install script, not both')
  }
  validate_array($allowed_users)
  validate_array($key_option_specs)
  validate_re($vault, '^https?://[-a-zA-Z0-9\.]+(:\d+)?', 'invalid vault URL')

  # data mutation
  if size($cidr_list) > 0 {
    $_cidr_list = join(['--cidr-list ', '"', join($cidr_list, ','), '"'], '')
  } else {
    fail('cidr_list must contain at least one entry')
  }

  if size($exclude_cidr_list) > 0 {
    $_exclude_cidr_list = join(['--exclude-cidr-list ', '"', join($exclude_cidr_list, ','), '"'], '')
  } else {
    $_exclude_cidr_list = ''
  }

  if size($allowed_users) > 0 {
    $_allowed_users = join(['--allowed-users ', '"', join($allowed_users, ','), '"'], '')
  } else {
    $_allowed_users = ''
  }

  if size($key_option_specs) > 0 {
    $_key_option_specs = join(['--key-option-specs ', '"', join($key_option_specs, ','), '"'], '')
  } else {
    $_key_option_specs = ''
  }


  # resource instantiation
  if ($install_script_source) {
    # TODO: find a better directory to place this script in
    file { "/usr/local/bin/${name}-install-script":
      owner  => ${admin_user},
      group  => 'root',
      mode   => '440',
      before => Exec["Allow ssh access for ${name}"],
    }
    $_install_script = "--install-script=@/usr/local/bin/${name}-install-script"
  }
  elsif ($install_script_content) {
    $_install_script = "--install-script=${install_script_content}"
  }
  else {
    $_install_script = ''
  }

  Exec <| title == 'vault-bootstrap' |> ->
  exec { "Allow ssh access for ${name}":
    command     => "${::vault::bin_dir}/allow-ssh-access --admin-user=${admin_user} --default-user=${default_user} --key-type=${key_type} --port=${port} --key-bits=${key_bits} ${_cidr_list} ${_exclude_cidr_list} ${_allowed_users} ${_key_option_specs} ${_install_script}",
    # TODO: add --check option to allow-ssh-access script
    unless      => "${::vault::bin_dir}/allow-ssh-access --check --admin-user=${admin_user} --default-user=${default_user} --key-type=${key_type} --port=${port} --key-bits=${key_bits} ${_cidr_list} ${_exclude_cidr_list} ${_allowed_users} ${_key_option_specs} ${_install_script}",
    environment => "VAULT_ADDR=${_vault}",
    tries       => 7,   # wait up to 60 seconds - designed to work with a DNS address advertised by Consul using a max 60s service check
    try_sleep   => 10,
    require     => File["${::vault::bin_dir}/allow-ssh-access"],
  }

}
