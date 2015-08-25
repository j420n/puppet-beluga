define beluga::drupal_site (
  $db_user          = $name,
  $db_pass          = "${name}password",
  $db_name          = $name,
  $web_host         = 'localhost',
  $web_user         = 'www-data',
  $web_group        = 'www-data',
  $site_owner       = 'beluga',
  $site_url         = $name,
  $docroot          = "/var/www/drupal/${name}/current",
  $site_aliases     = [],
  $site_admin       = 'admin@localhost',
  $port             = $beluga::params::apache_port,
  $use_make_file    = 'false',
  $make_file_path   = 'undefined',
  $make_build_path  = "/var/www/drupal/${name}/drush_build",
  $drupal_repo      = "https://github.com/j420n/silex_d7.git",
  $clone_path       = "/tmp/drupal_repo",
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

    file { "${docroot}":
      target => "${make_build_path}/${name}",
      ensure => "link",
      owner  => $web_user,
      group  => $web_group,
      mode   => 775,
    }

    notify{ "Cloning Drupal repository from ${drupal_repo}": }
    exec{ 'clone-drupal':
      command => "/usr/bin/git clone ${drupal_repo} ${clone_path}",
      cwd     => "/tmp",
      onlyif => "/usr/bin/test ! -d ${clone_path}"
    }

    notify{ "Updating existing Drupal repository from ${drupal_repo}": }
    exec{ 'update-drupal':
      command => "/usr/bin/git pull origin master",
      cwd     => "${clone_path}",
      onlyif => "/usr/bin/test -d ${clone_path}"
    }

    notify{ "Removing previous drush build.": }
    exec{ 'remove_drush_build':
      command => "/bin/rm -rf ${make_build_path}/${name}",
    }

    notify{ "Make file found at ${$make_file_path}": }
    exec{ 'drush-make':
      command => "/usr/local/bin/drush make ${make_file_path} ${make_build_path}/${name}",
      require  => Exec['remove_drush_build'],
    }

    notify{ "Installing Drupal site.": }
    exec{ 'drush-install':
      require => Exec['drush-make'],
      cwd     => $docroot,
      command => "/usr/local/bin/drush --yes --verbose site-install silex --db-url=mysql://${db_user}:${db_pass}@localhost/${db_name} --account-name=admin --account-pass=password  --site-name='Silex Development'",
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
