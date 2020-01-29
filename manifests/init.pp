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
# @proxy
#   Proxy to use when installing pip packages/ruby gems.  Defaults to none.
#
# @manage_user
#   Whether this module should create a user to run pulp.  Defaults to false.
#
# @pulp_user
#   Name of pulp user.  Defaults to 'pulp'.
#
# @pulp_user_uid
#   UID for pulp user. Defaults to 500.
#
# @pulp_user_homedir
#   Pulp user homedir.  Defaults to pulp_media_root.
#
# @pulp_group
#   Pulp group.  Defaults to 'pulp'.
#
# @pulp_group_gid
#   GID for pulp group.  Defaults to 500.
#
# @pulp_media_root
#   Pulp media root.  Defaults to '/var/lib/pulp'.
#
class pulp_three (
  Boolean $install_prereqs,
  Boolean $manage_python,
  Boolean $manage_user,
  Array[String] $pulp_plugins,
  Data $proxy,
  String $python_version,
  String $pulp_user,
  Integer $pulp_user_uid,
  String $pulp_user_homedir,
  String $pulp_group,
  Integer $pulp_group_gid,
  String $pulp_media_root,
){

  if $install_prereqs {
    class { 'pulp_three::packages':
      pulp_plugins => $pulp_plugins,
    }
    contain 'pulp_three::packages'
  }

  if $manage_python {
    class { 'pulp_three::python':
      python_version => $python_version,
    }
    contain 'pulp_three::python'
  }

  if $manage_user {
    if empty($pulp_user_homedir) {
      $pulp_user_homedir_final = $pulp_media_root
    } else {
      $pulp_user_homedir_final = $pulp_user_homedir
    }
    class { 'pulp_three::user':
      pulp_user         => $pulp_user,
      pulp_user_uid     => $pulp_user_uid,
      pulp_user_homedir => $pulp_user_homedir_final,
      pulp_group        => $pulp_group,
      pulp_group_gid    => $pulp_group_gid,
    }
  }

}
