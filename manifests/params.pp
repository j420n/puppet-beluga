class beluga::params {
  $hiera_data_dir  = '/etc/beluga'
  $hiera_source_dir = 'puppet:///modules/beluga/hieradata'
  $owner = 'root'
  $group = 'root'
  $unzip_package = 'unzip'
  $php_gd_package = 'php5-gd'
  $php_package = 'php5-cli'
  $php_ini = '/etc/php5/apache2/php.ini'
  $php_postgres_package = 'php5-pgsql'
  $default_ruby_version = 'ruby-1.9'
  $home = '/home'
  $shell = '/bin/bash'

  $wget_package = 'wget'

  $beluga_users = hiera_hash('beluga::users',undef)
    if $beluga_users{
      create_resources ( beluga::user, $beluga_users )
    }

  $drupal_sites = hiera_hash('beluga::drupal_sites',undef)
    if $drupal_sites{
      create_resources ( beluga::drupal_site, $drupal_sites )
    }

  $custom_sites = hiera_hash('beluga::custom_sites',undef)
    if $custom_sites{
      create_resources ( beluga::custom_site, $custom_sites )
    }

  $install_jdk = true
  $jdk_package = 'default-jdk'
  $jre_package = 'default-jre'
  $apache_port = 8000
  $php_memory_limit = hiera('beluga::params:php_memory_limit','256M')

  $lamp_servers = [{
  name          => 'lamp_servers',
  host          => '127.0.0.1',
  port          => 8000,
  upstream_port => 8881
  }]

  $lamp_admin_servers = [{
  name          => 'lamp_admin_servers',
  host          => '127.0.0.1',
  port          => 8000,
  upstream_port => 8000
  }]

  $solr_servers = [{
  name          => 'solr',
  host          => '127.0.0.1',
  port          => 8081,
  upstream_port => 8080
  }]

  $graylog_servers = [{
  name          => 'graylog',
  host          => '127.0.0.1',
  port          => 8000,
  upstream_port => 8000
  }]

  case $::osfamily {
    'RedHat': {

    }
    'Debian': {

    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
