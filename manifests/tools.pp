#
# == Class: vault::tools
#
# Deploy and configure tools for use with Vault.
#
# === Parameters
#
# [*lease_duration*]
#   String.  Length of time that managed resources will be valid.  This is
#   passed directly to Vault as the lease time and must therefore be in a
#   suitable format for that.
#   Default: 168h  (== 1 week)
#
# [*rotate_frequency*]
#   String.  How often to rotate a managed resource.
#   Default: daily
#   Valid values: hourly, daily, weekly, monthly, yearly
#
# === Example usage
#
# In Hiera:
#
#   vault::tools::lease_duration: '168h'
#   vault::tools::rotate_frequency: 'daily'
#
# This class needn't be instantiated - the defined types that use the tools
# installed by it "include" it.
#
class vault::tools(
  $lease_duration   = '168h',
  $rotate_frequency = 'daily',
) {

  ensure_packages('jq')

  file { '/usr/local/bin/deploy-ssl-certificate':
    source  => 'puppet:///modules/vault/deploy-ssl-certificate',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['jq'],
  }

  file { '/usr/local/bin/vault-auth-app':
    source => 'puppet:///modules/vault/vault-auth-app',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

}
