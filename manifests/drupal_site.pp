define beluga::drupal_site (
  $db_user = $name,
  $db_pass = "${name}password",
  $db_name = $name,
  $web_host = 'localhost',
  $web_user = 'www-data',
  $web_group = 'www-data',
  $site_owner = 'beluga',
  $site_url = $name,
  $site_aliases = [],
  $site_admin = 'admin@localhost',

){

  mysql_user { ["${db_user}@${web_host}"]:
    ensure => 'present',
    password_hash => mysql_password($db_pass),
  } ->

  mysql_grant { ["${db_user}@${web_host}"]:
    ensure     => "present",
    options    => ["GRANT"],
    privileges => ["ALL"],
    table      => "*.*",
    user       => ["${db_user}@${web_host}"],
  }
  mysql_database { "${db_name}":
    ensure  => "present",
    charset => "utf8",
  }
  if ! defined (File["/var/www/private/"]) {
    file { "/var/www/private/":
      ensure => "directory",
      owner  => "co",
      group  => "www-data",
      mode   => 775,
    }
  }
  if ! defined (File["/var/www/files/"]) {
    file { "/var/www/files/":
      ensure => "directory",
      owner  => "co",
      group  => "www-data",
      mode   => 775,
    }
  }
  if ! defined (File["/var/www/drupal/"]) {
    file { "/var/www/drupal/":
      ensure => "directory",
      owner  => "co",
      group  => "www-data",
      mode   => 775,
    }
  }
  file {[ "/var/www/private/${name}/", "/var/www/files/${name}/", "/var/www/drupal/${name}/"]:
    ensure => "directory",
    owner => "co",
    group => "www-data",
    mode => 775,
  }
  file {"/var/www/drupal/${name}/logs":
    ensure => "directory",
    owner => $web_user,
    group => $web_group,
  }
  apache::vhost { $site_url:
    override      => "All",
    port          => 80,
    manage_docroot  => false,
    docroot       => "/var/www/drupal/${name}/current",
    docroot_owner => $site_owner,
    docroot_group => $web_group,
    serveradmin   => $site_admin,
    serveraliases => $site_aliases,
    log_level     => "warn",
    logroot => "/var/www/drupal/${name}/logs",
  }
}
