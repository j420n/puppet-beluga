define beluga::drupal_site (
  $db_user = hiera("beluga::drupal_site::${name}::db_user", $name),
  $db_pass = hiera("beluga::drupal_site::${name}::db_pass", "${name}password"),
  $db_name = hiera("beluga::drupal_site::${name}::db_name", $name),
  $web_host = 'localhost',
  $web_user = hiera("beluga::drupal_site::${name}::web_user",'www-data'),
  $web_group = hiera("beluga::drupal_site::${name}::web_group",'www-data'),
  $docroot = hiera("beluga::drupal_site::${name}::docroot","/var/www/drupal/${name}/current"),
  $drupal_site_dir = hiera("beluga::drupal_site::drupal_site_dir","/var/www/drupal"),
  $drupal_file_dir = hiera("beluga::drupal_site::drupal_file_dir","/var/www/files"),
  $private_file_dir = hiera("beluga::drupal_site::private_file_dir","/var/www/private"),
  $site_owner = hiera("beluga::drupal_site::${name}::site_owner",'beluga'),
  $site_url = hiera("beluga::drupal_site::${name}::site_url", $name),
  $site_aliases = hiera("beluga::drupal_site::${name}::site_aliases", $name),
  $site_admin = 'admin@localhost',
  $port = hiera("beluga::drupal_site::${name}::port", $beluga::params::apache_port),
  $ssl_port = hiera("beluga::drupal_site::${name}::ssl_port", $beluga::params::apache_ssl_port),
  $use_make_file = false,

){
  if ($use_make_file == true){
    $make_file_location = hiera("beluga::drupal_site::${name}::drush_make_file_location", 'undefined')
    $make_build_path = hiera("beluga::drupal_site::${name}::drush_make_build_path", "${drupal_site_dir}/${name}/stage")

    exec{ 'drush-make':
      command => "drush make ${make_file_location} ${make_build_path}",
      path    => "/usr/local/bin/:/bin/",
    }

  }

  mysql_user { ["${db_user}@${web_host}"]:
    ensure => 'present',
    password_hash => mysql_password($db_pass),
  } ->

  mysql_grant { ["${db_user}@${web_host}/${db_name}.*"]:
    ensure     => "present",
    options    => ["GRANT"],
    privileges => ["ALL"],
    table      => "${db_name}.*",
    user       => ["${db_user}@${web_host}"],
  }
  mysql_database { "${db_name}":
    ensure  => "present",
    charset => "utf8",
  }
  include beluga::drupal_common_files
  file {[ "${private_file_dir}/${name}/", "${drupal_file_dir}/${name}/", "${drupal_site_dir}/${name}/"]:
    ensure => "directory",
    owner => $site_owner  ,
    group => $web_group,
    mode => 775,
  }
  file {"${drupal_site_dir}/${name}/logs":
    ensure => "directory",
    owner => $web_user,
    group => $web_group,
  }
  include beluga::apache_frontend_server
  apache::vhost { $site_url:
    override        => "All",
    port            => $port,
    ssl             => false,
    manage_docroot  => false,
    docroot         => $docroot,
    docroot_owner   => $site_owner,
    docroot_group   => $web_group,
    serveradmin     => $site_admin,
    serveraliases   => $site_aliases,
    log_level       => "warn",
    logroot         => "${drupal_site_dir}/${name}/logs",
    rewrites        => [
      {
        rewrite_rule => ['^index\.html$ welcome.html'],
        rewrite_rule => ['^/update.php / [L,R=404]'],
        rewrite_rule => ['^/install.php / [L,R=404]'],
        rewrite_rule => ['^/CHANGELOG.txt / [L,R=404]'],
        rewrite_rule => ['^/COPYRIGHT.txt / [L,R=404]'],
        rewrite_rule => ['^/INSTALL.mysql.txt / [L,R=404]'],
        rewrite_rule => ['^/INSTALL.pgsql.txt / [L,R=404]'],
        rewrite_rule => ['^/INSTALL.sqlite.txt / [L,R=404]'],
        rewrite_rule => ['^/INSTALL.txt / [L,R=404]'],
        rewrite_rule => ['^/LICENSE.txt / [L,R=404]'],
        rewrite_rule => ['^/MAINTAINERS.txt / [L,R=404]'],
        rewrite_rule => ['^/README.txt / [L,R=404]'],
        rewrite_rule => ['^/UPGRADE.txt / [L,R=404]'],
        rewrite_rule => ['^/authorize.php / [L,R=404]'],
        rewrite_rule => ['^/cron.php / [L,R=404]'],
        rewrite_rule => ['^/web.config / [L,R=404]'],
        rewrite_rule => ['^/xmlrpc.php / [L,R=404]'],
      },
    ],
  }
  #DRUPAL SSL VHOST
  include apache::mod::ssl 
  apache::vhost { "${site_url}-ssl" :
    override        => "All",
    port            => $apache_ssl_port,
    ssl             => true,
    manage_docroot  => false,
    docroot         => $docroot,
    docroot_owner   => $site_owner,
    docroot_group   => $web_group,
    serveradmin     => $site_admin,
    serveraliases   => $site_aliases,
    priority        => $vhost_priority,
    log_level       => $log_level,
    logroot         => "${drupal_site_dir}/${name}/logs",
    rewrites        => [
      {
        rewrite_rule => ['^index\.html$ welcome.html'],
        rewrite_rule => ['^/update.php / [L,R=404]'],
        rewrite_rule => ['^/install.php / [L,R=404]'],
        rewrite_rule => ['^/CHANGELOG.txt / [L,R=404]'],
        rewrite_rule => ['^/COPYRIGHT.txt / [L,R=404]'],
        rewrite_rule => ['^/INSTALL.mysql.txt / [L,R=404]'],
        rewrite_rule => ['^/INSTALL.pgsql.txt / [L,R=404]'],
        rewrite_rule => ['^/INSTALL.sqlite.txt / [L,R=404]'],
        rewrite_rule => ['^/INSTALL.txt / [L,R=404]'],
        rewrite_rule => ['^/LICENSE.txt / [L,R=404]'],
        rewrite_rule => ['^/MAINTAINERS.txt / [L,R=404]'],
        rewrite_rule => ['^/README.txt / [L,R=404]'],
        rewrite_rule => ['^/UPGRADE.txt / [L,R=404]'],
        rewrite_rule => ['^/authorize.php / [L,R=404]'],
        rewrite_rule => ['^/cron.php / [L,R=404]'],
        rewrite_rule => ['^/web.config / [L,R=404]'],
        rewrite_rule => ['^/xmlrpc.php / [L,R=404]'],
      },
    ],
    custom_fragment => "#This is a custom comment fragment.",
  }
  include nginx
  include nginx::config
  include nginx::service

  nginx::resource::vhost { $name:
    proxy_redirect => "http://${name}/ http://\$host/",
    proxy_set_header => ['X-Real-IP  $remote_addr', 'X-Forwarded-For $remote_addr', 'Host $host'],
    proxy => "http://upstream-$name",
  }

  nginx::resource::upstream { "upstream-$name":
    members => [
      'localhost:8000',
    ],
  }
}
