#
# == Class: vault
#
# Install and manage Vault.
#
# === Variables
#
# [*version*]
#   String.  Version of Vault to install.
#   Default: 0.2.0
#   Valid values: \d+\.\d+\.\d+
#
# [*user*]
#   String.  Username that vault will run as.
#   Default: root
#
# [*group*]
#   String.  Group that vault will run as.
#   Default: root
#
# [*manage_user*]
#   Boolean.  If set to true, this module will create the user if it doesn't
#   already exist.
#   Default: false
#
# [*manage_group*]
#   Boolean.  If set to true, this module will create the group if it
#   doesn't already exist.
#   Default: false
#
# [*debug*]
#   Boolean.  If true, this module will write the value of all variables to a
#   debug file.
#   Default: false
#
# [*debug_dir*]
#   String.  Fully qualified path to directory in which module debugging
#   file will be written.
#   Default: /var/lib/puppet/debug
#
# [*server*]
#   Boolean.  Configure Vault as a server.  If this is set to false, Vault
#   and the utility scripts this module provides will be installed, but the
#   Vault server will not be configured nor will the service be started.
#   Default: false
#
# [*bootstrap*]
#   Boolean.  Bootstrap the Vault instance, including setting up SSL,
#   running vault init, unsealing and safely distributing the initial root
#   token and unseal keys to the admins.
#   Default: false
#
# [*puppet_app_id*]
#   String.  When $bootstrap is true, specifies Puppet's app-id for
#   authenticating against the App ID auth backend.
#   Default: puppet  (it's recommended you don't use the default though)
#
# [*common_name*]
#   String.  The primary name to list on Vault's SSL certificate.
#   Default: vault
#
# [*alt_names*]
#   Array.  Additional names to list on Vault's SSL certificate.  Note that
#   hostnames should be prefixed with "DNS:" and IP addresses with "IP:".
#   Default: ["IP:${::ipaddress}"]
#
# [*admins*]
#   Array.  A list of usernames.  Accounts must exist, and each of those
#   accounts must have either a /home/<username>/.ssh/id_rsa.pub or
#   /home/<username>/.ssh/authorized_keys file that contains at least one
#   ssh public key, and they should be created before Class['vault'] to
#   guarantee success (as much as success *can* be guaranteed!).
#   Default: []
#
# [*init_style*]
#   String.  The type of init script/configuration to install.
#   Default: upstart
#   Valid values: upstart  (pull requests welcome to add support for others)
#
# [*config_file*]
#   String.  Full path of Vault configuration file.
#   Default: /etc/vault/config.hcl
#
# [*backend*]
#   String.  The storage backend to use.
#   Default: file
#   Valid values: consul, etcd, zookeeper, s3, mysql, inmem, file
#
# [*listener*]
#   String.  How vault listens for API requests.
#   Default: tcp
#   Valid values: tcp
#
# [*mlock*]
#   Boolean.  If true, prevents memory from being swapped to disk.  Note
#   that in production it is not recommended to set this to false unless you
#   use encrypted swap or do not use swap at all.
#   Default: true
#
# [*advertise_scheme*]
#   String.  Protocol over which this Vault instance is able to be reached.
#   Default: https
#   Valid values: https, http
#
# [*advertise_addr*]
#   String.  Address at which this Vault instance is able to be reached.
#   Default: $::ipaddress
#
# [*advertise_port*]
#   String. Port at which this Vault instance is able to be reached.
#   Default: 8200
#   Valid values: ^\d+$
#
# [*backend_path*]
#   String.  The path where data will be stored.  Used by several backends,
#   see the Consul documentation for your backend for example settings.
#   Default: /var/lib/vault
#
# [*backend_address*]
#   String.  The address of the backend being used.  Used by several
#   backends, see the Consul documentation for your backend for example
#   settings.
#   Default: false
#
# [*backend_scheme*]
#   String.  Protocol for talking to the Consul backend.
#   Default: http
#   Valid values: http, https
#
# [*backend_datacenter*]
#   String.  The datacenter to write to (Consul backend).
#   Default: false
#
# [*backend_token*]
#   String.  An access token to use to write data to Consul backend, or
#   session toekn to use to write to the S3 backend.
#   Default: false
#
# [*backend_bucket*]
#   String.  Name of the S3 bucket to use.  This is _required_ for the S3
#   backend.
#   Default: false
#
# [*backend_access_key*]
#   String.  AWS access key to use.  This is _required_ for the S3 backend.
#   Default: false
#
# [*backend_secret_key*]
#   String.  AWS secret key to use.  This is _required_ for the S3 backend.
#   Default: false
#
# [*backend_region*]
#   String.  AWS region to use.
#   Default: false
#
# [*backend_username*]
#   String.  MySQL username to connect with.  This is _required_ for the
#   MySQL backend.
#   Default: vault
#
# [*backend_password*]
#   String.  MySQL password to connect with.  THis is _required_ for the
#   MySQL backend.
#   Default: false
#
# [*backend_database*]
#   String.  Name of the MySQL database to use (MySQL backend).
#   Default: vault
#
# [*backend_table*]
#   String.  Name of the MySQL database table to use (MySQL backend).
#   Default: vault
#
# [*listener_address*]
#   String.  Address that the listener will bind to.
#   Default: 0.0.0.0
#
# [*listener_port*]
#   String.  Port that the listener will bind to.
#   Default: 8200
#
# [*tls_cert_file*]
#   String.  Path to an existing certificate for TLS.  If not specified, a
#   certificate and key will be automatically generated.
#   Default: false
#
# [*tls_key_file*]
#   String.  Path to an existing private key for TLS.  If not specified, a
#   certificate and key will be automatically generated.
#   Default: false
#
# [*stats_type*]
#   String.  Protocol for telemetry data.  If false, telemetry will not be
#   activated.
#   Default: false
#   Valid values: statsite, statsd
#
# [*stats_address*]
#   String.  Address to send telemetry to.
#   Default: 127.0.0.1:8125
#
# [*stats_host_prefix*]
#   Boolean.  If true, telemetry is prefixed with machine hostname.
#   Default: true
#
# [*lease_duration*]
#   String.  The default lease duration for use by various resources.  This
#   is the maximum length of time in seconds (no suffix) or hours (an 'h'
#   suffix) data obtained from Vault should be considered valid.
#   Default: 168h  (one week)
#
# [*rotate_frequency*]
#   String.  The default frequency at which to rotate data obtained from
#   Vault, for use by various resources.
#   Default: daily
#   Valid values: hourly, daily, weekly, monthly, yearly
#
# === Example usage
#
#  include vault
#
class vault(
  $version            = '0.4.0',
  $user               = 'root',
  $group              = 'root',
  $manage_user        = false,
  $manage_group       = false,
  $bin_dir            = '/usr/local/bin',
  $download_url       = undef,
  $download_url_base  = 'https://releases.hashicorp.com/vault',
  $download_extension = 'zip',
  $debug              = false,
  $debug_dir          = '/var/lib/puppet/debug',
  $server             = false,
  $bootstrap          = false,
  $puppet_app_id      = 'puppet',
  $common_name        = 'vault',
  $alt_names          = ["IP:${::ipaddress}"],
  $admins             = [],
  $init_style         = $::vault::params::init_style,
  $config_file        = '/etc/vault/config.hcl',
  $backend            = 'file',
  $listener           = 'tcp',
  $mlock              = true,
  $advertise_scheme   = 'https',
  $advertise_addr     = $::ipaddress,
  $advertise_port     = '8200',
  $backend_path       = '/var/lib/vault',
  $backend_address    = false,
  $backend_scheme     = 'http',
  $backend_datacenter = false,
  $backend_token      = false,
  $backend_bucket     = false,
  $backend_access_key = false,
  $backend_secret_key = false,
  $backend_region     = false,
  $backend_username   = 'vault',
  $backend_password   = false,
  $backend_database   = 'vault',
  $backend_table      = 'vault',
  $listener_address   = '0.0.0.0',
  $listener_port      = '8200',
  $tls_cert_file      = undef,
  $tls_key_file       = undef,
  $stats_type         = false,
  $stats_address      = '127.0.0.1:8125',
  $stats_host_prefix  = true,
  $lease_duration     = '168h',
  $rotate_frequency   = 'daily',
) inherits vault::params {

  # validate inputs
  validate_re($version, '^\d+\.\d+\.\d+$', 'vault version is not valid')
  validate_bool($debug)
  validate_absolute_path($debug_dir)
  validate_bool($server)
  validate_bool($bootstrap)
  validate_string($common_name)
  validate_array($alt_names)
  validate_array($admins)
  validate_re($init_style, '^(upstart|systemd)$', 'vault init_style is not valid')
  validate_absolute_path($config_file)
  validate_re($backend, '^(consul|etcd|zookeeper|s3|mysql|inmem|file)$', 'invalid vault backend')
  validate_re($listener, '^tcp$', 'invalid vault listener')
  validate_bool($mlock)
  validate_string($advertise_addr)
  if $backend_path { validate_string($backend_path) }
  if $backend_address { validate_string($backend_address) }
  validate_re($backend_scheme, '^(http|https)$', 'invalid vault backend_scheme')
  if $backend_datacenter { validate_string($backend_datacenter) }
  if $backend_token { validate_string($backend_token) }
  if $backend_bucket { validate_string($backend_bucket) }
  if $backend_access_key { validate_string($backend_access_key) }
  if $backend_secret_key { validate_string($backend_secret_key) }
  if $backend_region { validate_string($backend_region) }
  validate_string($backend_username)
  if $backend_password { validate_string($backend_password) }
  validate_string($backend_database)
  validate_string($backend_table)
  validate_string($listener_address)
  if $tls_cert_file { validate_absolute_path($tls_cert_file) }
  if $tls_key_file { validate_absolute_path($tls_key_file) }
  if $stats_type { validate_re($stats_type, '^(statsite|statsd)$', 'invalid vault stats_type') }
  validate_string($stats_address)
  validate_bool($stats_host_prefix)

  if $bootstrap and size($admins) == 0 {
    fail('vault requires at least one admin when bootstrap is enabled')
  }
  $admins_string = join($admins, ' ')
  $alt_names_string = join($alt_names, ',')

  # derived settings
  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    default:           {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }
  $os = downcase($::kernel)
  $real_download_url = pick($download_url, "${download_url_base}/${version}/vault_${version}_${os}_${arch}.${download_extension}")

  # instantiate managed resources
  class { 'vault::install': }

  if $server {
    Class['vault::install'] ->
    class { 'vault::config': } ~>
    class { 'vault::service': }
  }


  if $debug {
    class { 'vault::debug': }
  }

}
