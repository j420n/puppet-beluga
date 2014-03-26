class beluga::python_frontend(){

  class { 'python':
    version    => 'system',
    virtualenv => true,
    pip => true,
    dev => true,  #we need dev to use pip to install dependencies
  }

  class { "uwsgi": }
}
