class pulp_three::install (
  $pulp_media_root,
  $pulp_working_dir,
  $pulp_install_dir,
  $proxy_server = undef,
  $pulp_user,
  $pulp_group,
  $pulp_plugins,
){

  file { $pulp_media_root:
    ensure => directory,
    owner  => $pulp_user,
    group  => $pulp_group,
    mode   => '0755',
  }

  file { $pulp_working_dir:
    ensure  => directory,
    owner   => $pulp_user,
    group   => $pulp_group,
    mode    => '0755',
  }

  python::pyvenv { 'pulpvenv' :
    ensure     => present,
    version    => '3.6',
    systempkgs => true,
    venv_dir   => $pulp_install_dir,
    owner      => $pulp_user,
    group      => $pulp_group,
  }

  if 'pulp_rpm' in $pulp_plugins {
    python::pip { 'scikit-build':
      virtualenv => $pulp_install_dir,
      proxy      => $proxy_server,
    }

    python::pip { 'nose':
      virtualenv => $pulp_install_dir,
      proxy      => $proxy_server,
    }
  }

  $pulp_default_plugins =  [ 'pulpcore', 'pulp-file' ]

  $pulp_plugins_final = unique($pulp_default_plugins + $pulp_plugins)

  python::pip { $pulp_plugins_final:
    virtualenv => $pulp_install_dir,
    proxy      => $proxy_server,
  }

}
