class beluga::drupal_common_files() {
  file { "${private_file_dir}/":
    ensure => "directory",
    owner  => hiera("beluga::drupal_site::private_file_dir_owner", "${site_owner}"),
    group  => $web_group,
    mode   => 775,
  }
  file { "${drupal_file_dir}/":
    ensure => "directory",
    owner  => hiera("beluga::drupal_site::drupal_file_dir_owner", "${site_owner}"),
    group  => $web_group,
    mode   => 775,
  }
  file { "${drupal_site_dir}/":
    ensure => "directory",
    owner  => hiera("beluga::drupal_site::drupal_site_dir_owner", "${site_owner}"),
    group  => $web_group,
    mode   => 775,
  }

}
