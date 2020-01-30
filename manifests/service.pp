class pulp_three::service (
  $pulp_settings_file,
  $pulp_install_dir,
  $pulp_user,
  $pulp_group,
  $pulp_content_bind_address,
  $pulp_content_bind_port,
  $pulp_api_bind_address,
  $pulp_api_bind_port,
  $pulp_worker_ids,
){

  systemd::unit_file { 'pulpcore-content.service':
    content => epp('pulp_three/pulpcore-content.service.epp', {
      'pulp_settings_file'        => $pulp_settings_file,
      'pulp_install_dir'          => $pulp_install_dir,
      'pulp_user'                 => $pulp_user,
      'pulp_content_bind_address' => $pulp_content_bind_address,
      'pulp_content_bind_port'    => $pulp_content_bind_port,
    }),
    mode    => '0644',
  }
  ~> service { 'pulpcore-content':
    ensure    => running,
    enable    => true,
    subscribe => [
      Systemd::Unit_file['pulpcore-content.service'],
    ],
  }

  systemd::unit_file { 'pulpcore-api.service':
    content => epp('pulp_three/pulpcore-api.service.epp', {
      'pulp_settings_file'    => $pulp_settings_file,
      'pulp_install_dir'      => $pulp_install_dir,
      'pulp_user'             => $pulp_user,
      'pulp_api_bind_address' => $pulp_api_bind_address,
      'pulp_api_bind_port'    => $pulp_api_bind_port,
    }),
    mode    => '0644',
  }
  ~> service { 'pulpcore-api':
    ensure    => running,
    enable    => true,
    subscribe => [
      Systemd::Unit_file['pulpcore-api.service'],
    ],
  }

  systemd::unit_file { 'pulpcore-resource-manager.service':
    content => epp('pulp_three/pulpcore-resource-manager.service.epp', {
      'pulp_settings_file' => $pulp_settings_file,
      'pulp_install_dir'   => $pulp_install_dir,
      'pulp_user'          => $pulp_user,
    }),
    mode    => '0644',
  }
  ~> service { 'pulpcore-resource-manager':
    ensure    => running,
    enable    => true,
    subscribe => [
      Systemd::Unit_file['pulpcore-resource-manager.service'],
    ],
  }

  $pulp_worker_ids.each |$worker_id| {
    systemd::unit_file { "pulpcore-worker@${worker_id}.service":
      content => epp('pulp_three/pulpcore-worker.service.epp', {
        'worker_id'          => $worker_id,
        'pulp_settings_file' => $pulp_settings_file,
        'pulp_install_dir'   => $pulp_install_dir,
        'pulp_user'          => $pulp_user,
        'pulp_group'         => $pulp_group,
      }),
      mode    => '0644',
    }
    ~> service { "pulpcore-worker@${worker_id}":
      ensure    => running,
      enable    => true,
      subscribe => [
        Systemd::Unit_file["pulpcore-worker@${worker_id}.service"],
      ],
    }
  }

}
