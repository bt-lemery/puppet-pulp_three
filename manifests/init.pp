# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pulp_three
#
# @install_prereqs
#   Specifies whether to allow this module to install any rpms required by your chosen pulp plugins.
#
# @pulp_plugins
#   Array of pulp plugins to install in addition to 'pulpcore'.
#
# @manage_python
#   Specifies whether to allow this module to install a Python interpreter from SCL.
#
# @python_version
#   Python version to install from SCL.  Defaults to 'rh-python36'.
#
class pulp_three (
  Boolean $install_prereqs,
  Boolean $manage_python,
  Array[String] $pulp_plugins,
  Variant[Stdlib::Httpurl,String[0,0]] $http_proxy,
){

  if $install_prereqs {
    class { 'pulp_three::packages':
      pulp_plugins => $pulp_plugins,
    }
    contain 'pulp_three::install_prereqs'
  }

  if $manage_python {
    class { 'pulp_three::python':
      python_version => $python_version,
    }
    contain 'pulp_three::python'
  }

}
