define beluga::drupal_site (
  $db_user          = $name,
  $db_pass          = "${name}password",
  $db_name          = $name,
  $docroot          = "${drupal_site_dir}/${name}/current",
  $port             = $beluga::params::apache_port,
  $ssl_port         = $beluga::params::apache_ssl_port,
  $site_url         = $name,
  $site_aliases     = $name ,
  $site_owner       = 'beluga',
  $site_admin       = 'admin@localhost',
  $web_host         = 'localhost',
  $web_user         = 'www-data',
  $web_group        = 'www-data',
  $private_file_dir = '/var/www/private',
  $drupal_site_dir  = '/var/www/drupal',
  $drupal_file_dir  = '/var/www/files',
  $use_make_file    = 'false',
  $make_file_path   = 'undefined',
  $make_build_path  = "${drupal_site_dir}/${name}/current"

){
  if ($use_make_file == true){

    file { "${private_file_dir}/drush-make-builds":
      ensure => "directory",
      owner  => $web_user,
      group  => $web_group,
      mode   => 775,
    }

    file { "${private_file_dir}/drush-make-builds/${name}":
      ensure => "directory",
      owner  => $web_user,
      group  => $web_group,
      mode   => 775,
    }

    file { "${docroot}":
      target => "${private_file_dir}/drush-make-builds/${name}",
      ensure => "link",
      owner  => $web_user,
      group  => $web_group,
      mode   => 775,
    }

    notify{ "Removing previous drush build.": }
    file {'remove_drush_build':
      ensure => absent,
      path => "${private_file_dir}/drush-make-builds/${name}/test",
      recurse => true,
      purge => true,
      force => true,
    }

    notify{ "Make file found at ${$make_file_path}": }
    exec{ 'drush-make':
    command => "/usr/local/bin/drush make ${make_file_path} ${make_build_path}",
    require  => File['remove_drush_build'],
    }

    notify{ "Installing Drupal site.": }
    exec{ 'drush-install':
      require => Exec['drush-make'],
      cwd     => "${make_build_path}",
      command => "drush --yes --verbose site-install silex --db-url=mysql://silex:silexpassword@localhost/silex --account-name=admin --account-pass=password  --site-name='Silex Development'",
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
