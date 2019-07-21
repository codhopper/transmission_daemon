# @summary Install the transmission daemon, manage it and configure settings
#
# A description of what this class does
#
# @example
#   include transmission_daemon
class transmission_daemon(

  Boolean $manage_install    = true,
  Boolean $manage_service    = true,
  Hash $settings             = {},
  String $settings_json_file = '/var/lib/transmission/.config/transmission-daemon/settings.json',
  String $transmission_owner = 'transmission',
  String $transmission_group = 'transmission',

) {

  if ( $manage_install) {
    package{ ['transmission-daemon','transmission-common']:
      ensure => installed,
    }
  }

  if ( $manage_service) {
    service{ 'transmission-daemon':
      ensure => running,
      enable => true,
    }
  }
 
  if ( $manage_service ) and ( $manage_install ) {
    Package['transmission-daemon','transmission-common']
    -> Service['transmission-daemon']
  }

  file{ $settings_json_file:
    ensure  => file,
    owner   => $transmission_owner,
    group   => $transmission_group,
    mode    => '0600',
    content => epp('transmission_daemon/settings.json.epp', {settings => $settings }),
  }

  exec{ 'reload-settings-from-disk':
    command   => 'kill -s HUP $(pidof transmission-daemon)',
    path      => '/sbin:/bin:/usr/sbin:/usr/bin',
    unless    => 'pidof transmission-daemon',
    subscribe => File[$settings_json_file],
  }

}
