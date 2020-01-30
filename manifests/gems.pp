class pulp_three::gems (
  $pulp_plugins,
  $pulp_admin_password,
  $proxy_server,
){

  package { 'pulpcore_client_gem':
    ensure          => '3.0.1',
    name            => 'pulpcore_client',
    provider        => 'puppet_gem',
    install_options => [
      {
        '--http-proxy' => $proxy_server,
      },
    ],
  }

  if 'pulp_rpm' in $pulp_plugins {
    package { 'pulp_rpm_client_gem':
      ensure          => '3.0.0',
      name            => 'pulp_rpm_client',
      provider        => 'puppet_gem',
      install_options => [
        {
          '--http-proxy' => $proxy_server,
        },
      ],
    }
  }

  file { '/etc/puppetlabs/swagger.yaml':
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('pulp_three/swagger.yaml.epp', {
      'pulp_admin_password' => $pulp_admin_password,
    }),
  }

}
