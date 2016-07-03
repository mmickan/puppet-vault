#
# == Class: vault::params
#
# OS-specific default parameters.
#
# === Example usage
#
# This class should not be called directly.
#
class vault::params {

  case $::operatingsystem {
    'Ubuntu': {
      if versioncmp($::operatingsystemrelease, '8.04') < 1 {
        fail('Unsupported OS')
      } elsif versioncmp($::operatingsystemrelease, '15.04') < 0 {
        $init_style = 'upstart'
      } else {
        $init_style = 'systemd'
      }
    }
    'Debian': {
      if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
        $init_style = 'systemd'
      }
    }
    /^(CentOS|RedHat|Scientific)$/: {
      if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
        $init_style = 'systemd'
      } else {
        fail('Unsupported OS')
      }
    }
    default: {
      fail('Unsupported OS')
    }
  }

}
