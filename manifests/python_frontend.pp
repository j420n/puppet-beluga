class beluga::python_frontend(){

  class { 'python':
    version    => 'system',
    virtualenv => true,
    pip => true,
  }

  class { "uwsgi": }
}
