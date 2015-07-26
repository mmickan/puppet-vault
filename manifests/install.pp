#
# == Class: vault::install
#
# Install Vault.
#
# === Example usage
#
# This class is not called directly.
#
class vault::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # create directories if using default settings (NOTE: for non-default
  # settings, the directories must be created outside this module)
  if $vault::backend == 'file' and $vault::backend_path == '/var/lib/vault' {
    file { '/var/lib/vault':
      ensure => 'directory',
      owner  => $vault::user,
      group  => $vault::group,
      mode   => '0755',
    }
  }

  if $::operatingsystem != 'darwin' {
    ensure_packages(['unzip'])
  }
  staging::file { 'vault.zip':
    source => $vault::real_download_url
  } ->
  staging::extract { 'vault.zip':
    target  => $vault::bin_dir,
    creates => "${vault::bin_dir}/vault",
    require => Package['unzip'],
  } ->
  file { "${vault::bin_dir}/vault":
    owner => 'root',
    group => 0, # 0 intead of root because OS X uses "wheel"
    mode  => '0555',
  }

  if $vault::manage_user {
    user { $vault::user:
      ensure => 'present',
      system => true,
      groups => $vault::extra_groups,
    }

    if $vault::manage_group {
      Group[$vault::group] -> User[$vault::group]
    }
  }
  if $vault::manage_group {
    group { $vault::group:
      ensure => 'present',
      system => true,
    }
  }

}
