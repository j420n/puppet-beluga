class beluga::params {
  $hiera_data_dir  = '/etc/beluga'
  $hiera_source_dir = 'puppet:///modules/beluga/hieradata'
  $owner = 'root'
  $group = 'root'
  $unzip_package = 'unzip'
  $php_gd_package = 'php5-gd'
  $php_cli_package = 'php5-cli'
  $php_cgi_package = 'php5-cgi'
  $php_curl_package = 'php5-curl'
  $php_mcrypt_package = 'php5-mcrypt'
  $php_mysql_package = 'php5-mysql'
  $php_common_package = 'php5-common'
  $php_ini = '/etc/php5/apache2/php.ini'
  $php_postgres_package = 'php5-pgsql'
  $default_ruby_version = 'ruby-1.9'
  $home = '/home'
  $shell = '/bin/bash'

  $wget_package = 'wget'

  $install_jdk = true
  $jdk_package = 'default-jdk'
  $jre_package = 'default-jre'
  $apache_port = 8000
  $apache_ssl_port = 443
  $install_php52 = false 
  $php_memory_limit = '256M'

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
