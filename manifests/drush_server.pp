class beluga::drush_server(){

  class { 'composer':
    target_dir => '/usr/local/bin',
  }
  include 'beluga::php'
  $drush_exec_dir = '/usr/local/bin'
  $drush_target_dir = '/usr/local/lib/composer/vendor/bin'

  file {'/usr/local/lib/composer':
    ensure => 'directory',
  }

  exec { 'install-drush':
    path      => ['/usr/bin', '/usr/sbin', '/bin', '/usr/local/bin'],
    environment => ['COMPOSER_HOME=/usr/local/lib/composer/'],
    command   => "composer global require drush/drush:6.* --no-interaction --working-dir=/usr/local/lib/composer",
    onlyif    => "test ! -f ${drush_exec_dir}/drush",
    require   => [Class['composer', 'beluga::php'], File['/usr/local/lib/composer']],
  }

  # Symlink drush executable
  file { "${drush_exec_dir}/drush":
    ensure    => 'link',
    target    => "${drush_target_dir}/drush",
  }

}
