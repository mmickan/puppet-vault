#
# == Define: vault::validate_vault_connection
#
# This type validates that a successful connection can be established the
# node on which this resource is run and a specified vault instance.
#
# === Parameters
#
# [*title*]
#   The hostname of the vault server to connect to.
#
# [*protocol*]
#   String.  Protocol used to connect to the vault server.
#   Default: https
#
# [*port*]
#   Integer.  Port number used to connect to the vault server.
#   Default: 8200
#
# [*sleep*]
#   Integer.  Number of seconds to sleep between connection attempts.
#   Default: 4
#
# [*tries*]
#   Integer.  Number of connection attempts before accepting failure.
#   Default: 30
#
# === Example usage
#
#  vault::validate_vault_connection { 'title':
#    protocol => 'protocol value',
#  }
#
define vault::validate_vault_connection(
  $protocol = 'https',
  $port     = 8200,
  $sleep    = 4,
  $tries    = 30,
) {

  $validate_cmd = "curl ${protocol}://${title}:${port}/v1/sys/health -o /dev/null"
  $exec_name = "validate connection to Vault at ${protocol}://${title}:${port}"

  exec { $exec_name:
    command   => $validate_cmd,
    unless    => $validate_cmd,
    cwd       => '/tmp',
    logoutput => 'on_failure',
    path      => '/bin:/usr/bin:/usr/local/bin',
    tries     => $tries,
    try_sleep => $sleep,
  }


}
