class beluga::params {
  $hiera_data_dir  = '/etc/beluga'
  $hiera_source_dir = 'puppet:///modules/beluga/hieradata'
  $owner = 'root'
  $group = 'root'
  $unzip_package = 'unzip'
  $php_gd_package = 'php5-gd'
  $php_package = 'php5-cli'
  $php_postrges_package = 'php5-pgsql'
  $default_ruby_version = 'ruby-1.9'
  $home = '/home'
  $shell = '/bin/bash'

  $wget_package = 'wget'

  $install_jdk = 'present'
  $jdk_package = 'default-jdk'

  $lamp_servers = {
  name          => 'lamp_servers',
  host          => '127.0.0.1',
  port          => 8000,
  upstream_port => 8881
  }

  $lamp_admin_servers = {
  name          => 'lamp_admin_servers',
  host          => '127.0.0.1',
  port          => 8000,
  upstream_port => 8000
  }

  $solr_servers = {
  name          => 'solr',
  host          => '127.0.0.1',
  port          => 8081,
  upstream_port => 8080
  }

  $graylog_servers = {
  name          => 'graylog',
  host          => '127.0.0.1',
  port          => 8000,
  upstream_port => 8000
  }

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
