define beluga::drupal_site (
  $db_user = $name,
  $db_pass = "${name}password",
  $db_name = $name,
  $web_host = 'localhost',
  $web_user = 'www-data',
  $web_group = 'www-data',
  $site_owner = 'beluga',
  $site_url = $name,
  $docroot = "/var/www/drupal/${name}/current",
  $site_aliases = [],
  $site_admin = 'admin@localhost',
  $port = $beluga::params::apache_port,
  $use_make_file    = 'false',
  $make_file_path   = 'undefined',
  $make_build_path  = "/var/www/drupal/${name}/drush_build",
){
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
  file {[ "/var/www/private/${name}/", "/var/www/files/${name}/", "/var/www/drupal/${name}/"]:
    ensure => "directory",
    owner => $site_owner  ,
    group => $web_group,
    mode => 775,
  }
  file {"/var/www/drupal/${name}/logs":
    ensure => "directory",
    owner => $web_user,
    group => $web_group,
  }
  include beluga::apache_frontend_server

  if $use_make_file{
    file { $make_build_path:
      ensure => "directory",
      owner => $web_user,
      group => $web_group,
    }



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
      command => "/usr/bin/local/drush --yes --verbose site-install silex --db-url=mysql://silex:silexpassword@localhost/silex --account-name=admin --account-pass=password  --site-name='Silex Development'",
    }

  }

  apache::vhost { $site_url:
    override      => "All",
    port          => $port,
    manage_docroot  => false,
    docroot       => $docroot,
    docroot_owner => $site_owner,
    docroot_group => $web_group,
    serveradmin   => $site_admin,
    serveraliases => $site_aliases,
    log_level     => "warn",
    logroot => "/var/www/drupal/${name}/logs",
    rewrites => [
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
