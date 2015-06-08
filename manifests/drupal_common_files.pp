class beluga::drupal_common_files(
$pfd = hiera("beluga::drupal_site::private_file_dir",'/var/www/private'),
$dfd = hiera("beluga::drupal_site::drupal_file_dir",'/var/www/files'),
$dsd = hiera("beluga::drupal_site::drupal_site_dir",'/var/www/drupal'),
) {
  file { $pfd:
    ensure => "directory",
    owner  => $site_owner,
    group  => $site_owner,
    mode   => 755,
  }
  file { $dfd :
    ensure => "directory",
    owner  => $site_owner,
    group  => $web_group,
    mode   => 775,
  }
  file { $dsd :
    ensure => "directory",
    owner  => $site_owner,
    group  => $web_group,
    mode   => 775,
  }
}
