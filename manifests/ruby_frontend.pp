class beluga::ruby_frontend(
  $default_ruby_version = $beluga::params::default_ruby_version,
) {
  include rvm

  rvm_system_ruby {
    'ruby-1.9':
      ensure      => 'present',
      default_use => true,
  }
}
