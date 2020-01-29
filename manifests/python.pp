class pulp_three::python (
  $python_version,
){

  class { 'python' :
    ensure                      => present,
    version                     => $python_version,
    provider                    => 'rhscl',
    manage_scl                  => false,
    rhscl_use_public_repository => false,
    dev                         => 'present',
    virtualenv                  => 'present',
  }

  contain python

}
