class beluga::drush_server(){

  class { 'composer': }

  $drush_exec_dir = '/usr/local/bin'

  exec { 'install-drush':
    path      => ['/usr/bin', '/usr/sbin', '/bin', '/usr/local/bin'],
    command   => "composer global require drush/drush:6.*",
    onlyif    => "test ! -f ${drush_exec_dir}/drush",
    require   => Class['composer'],
  }

  # Symlink drush executable
  /*file { " ${drush_exec_dir}/drush":
    ensure    => 'link',
    target    => "${drush_exec_dir}/drush/drush",
    owner     => $tomcat_user,
    group     => $tomcat_group,
  }*/

}
