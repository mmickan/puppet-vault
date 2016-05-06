#
# == Define: vault::obtain_ssh_access
#
# Use Vault to generate an ssh key pair and deploy it, along with
# appropriate configuration in .ssh/config to allow access from the host
# this resource is applied to, to a given destination host (which must have
# allowed ssh access, usually by applying vault::allow_ssh_access to it).
#
# === Parameters
#
# [*name*]
#   The name used for the host entry in the .ssh/config file.  Also used in
#   the filename for the private key.
#
# [*role*]
#   The name of the role to use with Vault's SSH secret backend.  If using
#   this resource in combination with vault::allow_ssh_access, this should
#   match the name of that resource on the host to which access is desired.
#
# [*destination*]
#   The hostname or IP address of the host to which access is desired.  If
#   hostname is provided, it will be resolved to an IP address and the IP
#   address used in the request to Vault.
#
# [*local_username*]
#   The local username for which access will be provided.  Note that
#   local_username must exist before this resource is instantiated or the
#   SSH key will not be provisioned.
#
# [*homedir_template*]
#   An inline template to generate the home directory for the
#   $local_username user.
#   Default: '/home/<%= @local_username %>'
#
# [*remote_username*]
#   The remote username for which access will be requested.
#
# [*vault*]
#   String.  Base URL for Vault instance to connect to.
#   Default: based on advertise_scheme, advertise_addr and advertise_port in
#   vault class
#
# [*rotate_frequency*]
#
# === Example usage
#
#  vault::obtain_ssh_access { 'jenkins':
#    role            => 'jenkins.example.com_22',
#    destination     => 'jenkins.example.com',
#    remote_username => 'jenkins',
#    local_username  => 'jenkins',
#  }
#
define vault::obtain_ssh_access(
  $destination,
  $remote_username,
  $role,
  $homedir_template = '/home/<%= @local_username %>',
  $local_username   = 'root',
  $rotate_frequency = undef,
  $vault            = undef,
) {

  if ! defined(Class['vault']) {
    include vault
  }

  $_vault = $vault ? {
    undef   => "${::vault::advertise_scheme}://${::vault::advertise_addr}:${::vault::advertise_port}",
    default => $vault,
  }

  $_rotate_frequency = $rotate_frequency ? {
    undef   => $::vault::rotate_frequency,
    default => $rotate_frequency,
  }

  $_homedir = inline_template($homedir_template)

  # data validation
  validate_string($local_username)
  validate_string($remote_username)
  validate_string($role)
  validate_string($destination)
  validate_absolute_path($_homedir)

  # data mutation
  # TODO: convert $destination to IP address if hostname provided
  $destination_ip = $destination

  # resource instantiation.  Note that the onlyif parameter below prevents
  # Puppet from provisioning keys for users that do not exist yet - ensure
  # the $local_username user exists before this resource is instantiated
  Exec <| title == 'vault-bootstrap' |> ->
  exec { "Obtain SSH access for ${name}":
    command     => "${::vault::bin_dir}/obtain-ssh-access --name=${role} --ip=${destination_ip} --username=${remote_username} --output=${_homedir}/.ssh/${role}-id_rsa",
    onlyif      => "id ${local_username} && [ ! -f ${_homedir}/.ssh/${role}-id_rsa ]", # TODO: check for existing private key (puppet doesn't rotate keys)
    path        => '/bin:/usr/bin',
    environment => "VAULT_ADDR=${_vault}",
    tries       => 7,   # wait up to 60 seconds - designed to work with a DNS address advertised by Consul using a max 60s service check
    try_sleep   => 10,
    require     => File["${::vault::bin_dir}/obtain-ssh-access"],
  } ->
  cron { "Rotate SSH key for ${name}":
    command => "id ${local_username} >/dev/null 2>&1 && env VAULT_ADDR=${_vault} ${::vault::bin_dir}/obtain-ssh-access --name=${role} --ip=${destination_ip} --username=${remote_username} --output=~${_homedir}/.ssh/${role}-id_rsa",
    special => $_rotate_frequency,
    require => File["${::vault::bin_dir}/obtain-ssh-access"],
  }
  augeas { "SSH config host entry for ${name}":
    lens    => 'Ssh.lns',
    incl    => "${_homedir}/.ssh/config",
    context => "/files/${_homedir}/.ssh/config",
    changes => [
      "set Host[.='${role}'] ${role}",
      "set Host[.='${role}']/HostName ${destination_ip}",
      "set Host[.='${role}']/IdentityFile ${_homedir}/.ssh/${role}-id_rsa",
    ],
  }
  User <| name == $local_username |> -> Exec["Obtain SSH access for ${name}"]
  User <| name == $local_username |> -> Cron["Rotate SSH key for ${name}"]
  User <| name == $local_username |> -> Augeas["SSH config host entry for ${name}"]

}
