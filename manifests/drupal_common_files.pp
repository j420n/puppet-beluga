class beluga::drupal_common_files() {
  file { "/var/www/private/":
    ensure => "directory",
    owner  => $site_owner,
    group  => $web_group,
    mode   => 775,
  }
  file { "/var/www/files/":
    ensure => "directory",
    owner  => $site_owner,
    group  => $web_group,
    mode   => 775,
  }
  file { "/var/www/drupal/":
    ensure => "directory",
    owner  => $site_owner,
    group  => $web_group,
    mode   => 775,
  }

}