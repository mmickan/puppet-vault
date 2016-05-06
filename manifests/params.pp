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
    default: {
      fail('Unsupported OS')
    }
  }

}
