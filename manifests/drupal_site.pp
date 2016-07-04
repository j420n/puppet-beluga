define beluga::drupal_site (
  $db_user          = $name,
  $db_pass          = "${name}password",
  $db_name          = $name,
  $prefix           = '',
  $web_host         = 'localhost',
  $web_user         = 'www-data',
  $web_group        = 'www-data',
  $site_owner       = 'beluga',
  $site_url         = "${prefix}.${name}",
  $docroot          = "/var/www/drupal/${site_url}/current",
  $manage_docroot   = hiera("beluga::drupal_site::${name}::manage_docroot", $manage_docroot),
  $site_aliases     = [],
  $site_admin       = 'admin@localhost',
  $port             = $beluga::params::apache_port,
  $use_make_file    = 'false',
  $clone_drupal     = 'false',
  $make_file_path   = 'undefined',
  $install_profile  = 'silex',
  $admin_email      = 'root@localhost.localdomain',
  $make_build_path  = "/var/www/drupal/${docroot}/drush_build",
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
  file {[ "/var/www/private/${site_url}/", "/var/www/files/${site_url}/", "/var/www/drupal/${site_url}/"]:
    ensure => "directory",
    owner => $site_owner  ,
    group => $web_group,
    mode => 775,
  }
  file {"/var/www/drupal/${site_url}/logs":
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
      target => "${make_build_path}/${site_url}",
      ensure => "link",
      owner  => $web_user,
      group  => $web_group,
      mode   => 775,
    }
    if $clone_drupal{
      notify{ "Cloning Drupal repository from ${drupal_repo}": }
      exec{ "clone-drupal-${name}":
        command => "/usr/bin/git clone ${drupal_repo} ${clone_path}",
        cwd     => "/tmp",
        onlyif => "/usr/bin/test ! -d ${clone_path}"
      }

      notify{ "Updating existing Drupal repository from ${drupal_repo}": }
        exec{ "update-drupal-${name}":
        command => "/usr/bin/git pull origin master",
        cwd     => "${clone_path}",
        onlyif => "/usr/bin/test -d ${clone_path}"
      }
    }

    notify{ "Removing previous drush build for ${name}": }
    exec{ "remove_drush_build-${name}":
      command => "/bin/rm -rf ${make_build_path}/${site_url}",
    }

    notify{ "Make file found for ${name} at ${$make_file_path}": }
    exec{ "drush-make-${name}":
      command => "/usr/local/bin/drush make ${make_file_path} ${make_build_path}/${site_url}",
      require  => Exec["remove_drush_build-${name}"],
    }

    notify{ "Installing Drupal site for ${name}.": }
    exec{ "drush-install-${name}":
      require => Exec["drush-make-${name}"],
      cwd     => $docroot,
      command => "/usr/local/bin/drush --yes --verbose site-install ${install_profile} --db-url=mysql://${db_user}:${db_pass}@localhost/${db_name} --account-name=admin --account-pass=password --account-mail=${$admin_email} --site-name='Silex Development'",
    }

  }

  apache::vhost { $site_url:
    override      => "All",
    port          => $port,
    manage_docroot  => $manage_docroot,
    docroot       => $docroot,
    docroot_owner => $site_owner,
    docroot_group => $web_group,
    serveradmin   => $site_admin,
    serveraliases => $site_aliases,
    log_level     => "warn",
    logroot => "/var/www/drupal/${site_url}/logs",
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

  nginx::resource::vhost { $site_url:
    proxy_redirect => "http://${$site_url}/ http://\$host/",
    proxy_set_header => ['X-Real-IP  $remote_addr', 'X-Forwarded-For $remote_addr', 'Host $host'],
    proxy => "http://upstream-$site_url",
  }

  nginx::resource::upstream { "upstream-${site_url}":
    members => [
      'localhost:8000',
    ],
  }
}
