# documentation goes here
class pulp_three::migrations (
  $pulp_settings_file,
  $pulp_install_dir,
  $pulp_admin_password,
){

  exec { 'run_migrations':
    path        => "${pulp_install_dir}/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin",
    environment => [
      'DJANGO_SETTINGS_MODULE=pulpcore.app.settings',
      "PULP_SETTINGS=${pulp_settings_file}",
    ],
    command     => 'django-admin migrate --noinput',
    user        => 'pulp',
    group       => 'pulp',
    logoutput   => true,
    creates     => "${pulp_install_dir}/initial_setup_complete",
    before      => File["${pulp_install_dir}/initial_setup_complete"],
  }

  exec { 'reset_admin_pass':
    path        => "${pulp_install_dir}/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin",
    environment => [
      'DJANGO_SETTINGS_MODULE=pulpcore.app.settings',
      "PULP_SETTINGS=${pulp_settings_file}",
    ],
    command     => "django-admin reset-admin-password --password ${pulp_admin_password}",
    user        => 'pulp',
    group       => 'pulp',
    logoutput   => true,
    creates     => "${pulp_install_dir}/initial_setup_complete",
    before      => File["${pulp_install_dir}/initial_setup_complete"],
  }

  exec { 'collect_static_media':
    path        => "${pulp_install_dir}/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin",
    environment => [
      'DJANGO_SETTINGS_MODULE=pulpcore.app.settings',
      "PULP_SETTINGS=${pulp_settings_file}",
    ],
    command     => 'django-admin collectstatic --noinput',
    user        => 'pulp',
    group       => 'pulp',
    logoutput   => true,
    creates     => "${pulp_install_dir}/initial_setup_complete",
    before      => File["${pulp_install_dir}/initial_setup_complete"],
  }

  file { "${pulp_install_dir}/initial_setup_complete":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

}
