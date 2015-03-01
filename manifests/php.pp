class beluga::php(
  $memory_limit = $beluga::params::php_memory_limit,
  $install_php52 = $beluga::params::install_php52,
) inherits beluga::params {

  #you can use a global package parameter
  Package { ensure => "installed" }
  
  case $::osfamily {
    'RedHat': {

	if($install_php52 == true){
		$dependencies = [
		"libxml2-devel.x86_64", "pcre-devel.x86_64", "bzip2-devel.x86_64", "libcurl-devel.x86_64", "freetype-devel.x86_64", "libiodbc-devel.x86_64",
		"unixODBC.x86_64", "readline-devel.x86_64", "mysql-devel.x86_64", "httpd-devel.x86_64", "libpng-devel.x86_64", "libjpeg-devel.x86_64"
		]
		package{$dependencies:}->
		exec { "download-php52":
			cwd     => "/vagrant",
			command => "sudo curl -O http://museum.php.net/php5/php-5.2.17.tar.gz",
			path    => "/usr/local/bin/:/usr/bin/:/bin/",
		}->
		exec { "extract-php52":
			cwd     => "/vagrant",
			command => "tar -zxvf php-5.2.17.tar.gz",
			path    => "/usr/local/bin/:/usr/bin/:/bin/",
		}->
		package{ "php5-*":
			ensure => "purged",
		}->
		exec { "install-php52":
			cwd     => "/vagrant/php-5.2.17",
			command => "./configure  --build=x86_64-redhat-linux-gnu --host=x86_64-redhat-linux-gnu --target=x86_64-redhat-linux-gnu --program-prefix= --prefix=/usr --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64 --libexecdir=/usr/libexec --localstatedir=/var --sharedstatedir=/usr/com --mandir=/usr/share/man --infodir=/usr/share/info --cache-file=../config.cache --with-libdir=lib64 --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --disable-debug --with-pic --disable-rpath --without-pear --with-bz2 --with-curl --with-exec-dir=/usr/bin --with-freetype-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --without-gdbm --with-gettext --with-gmp --with-iconv --with-jpeg-dir=/usr --with-openssl --with-png --with-expat-dir=/usr --with-pcre-regex=/usr --with-zlib --with-layout=GNU --enable-exif --enable-ftp --enable-magic-quotes --enable-sockets --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-track-vars --enable-trans-sid --enable-yp --enable-wddx --with-kerberos --enable-ucd-snmp-hack --with-unixODBC=shared,/usr --enable-memory-limit --enable-shmop --enable-calendar --enable-dbx --enable-dio --without-mime-magic --without-sqlite --with-libxml-dir=/usr --with-xml --with-system-tzdata --enable-force-cgi-redirect --enable-pcntl --enable-mbstring=shared --enable-mbstr-enc-trans --enable-mbregex --with-gd=shared --enable-bcmath=shared --enable-dba=shared --with-db4=/usr --with-xmlrpc=shared --with-ldap=shared --with-ldap-sasl --with-mysql=shared,/usr --with-mysqli=shared,/usr/bin/mysql_config --enable-dom=shared --with-dom-xslt=/usr --with-dom-exslt=/usr --with-snmp=shared,/usr --enable-soap=shared --with-xsl=shared,/usr --enable-xmlreader=shared --enable-xmlwriter=shared --enable-fastcgi --enable-pdo --with-pdo-odbc=shared,unixODBC,/usr --with-pdo-mysql=/usr --enable-json=shared --enable-zip=shared --with-readline",
			path    => "/usr/local/bin/:/usr/bin/:/bin/",
		}


	}



    }
    'Debian': {
      package { $beluga::params::php_common_package: } ->
      package { $beluga::params::php_gd_package: } ->
      package { $beluga::params::php_cli_package: } ->
      package { $beluga::params::php_cgi_package: } ->
      package { $beluga::params::php_curl_package: } ->
      package { $beluga::params::php_mcrypt_package: } ->
      package { $beluga::params::php_mysql_package: } ->
      package { $beluga::params::php_postgres_package: }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  class {'mysql::bindings':
    php_enable         => true,
  }
  
  file {$beluga::params::php_ini:
    content => template('beluga/php.ini.erb'),
    require => Class['apache_frontend_server'],
  }
}
