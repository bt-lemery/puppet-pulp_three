class pulp_three::nginx (
  $nginx_package_name,
  $pulp_install_dir,
  $pulp_content_bind_address,
  $pulp_content_bind_port,
  $pulp_api_bind_address,
  $pulp_api_bind_port,
){

  class { '::nginx':
    confd_purge         => true,
    package_ensure      => present,
    package_name        => $nginx_package_name,
    manage_repo         => false,
    keepalive_timeout   => 5,
    types_hash_max_size => '4096',
    proxy_redirect      => 'off',
    accept_mutex        => 'off',
  }
  contain 'nginx'

  nginx::resource::server { $::fqdn:
    ensure               => present,
    www_root             => "${pulp_install_dir}/lib/python3.6/site-packages/rest_framework",
    use_default_location => false,
    index_files          => [],
  }

  nginx::resource::upstream { 'pulp':
    ensure  => present,
    members => [
      "${pulp_content_bind_address}:${pulp_content_bind_port}",
      "${pulp_api_bind_address}:${pulp_api_bind_port}",
    ],
  }

  nginx::resource::location { '/pulp/content/':
    ensure           => present,
    proxy_set_header => [
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto $scheme',
      'Host $http_host',
    ],
    proxy            => "http://${pulp_content_bind_address}:${pulp_content_bind_port}",
    server           => $::fqdn,
  }

  nginx::resource::location { '/pulp/api/v3/':
    ensure           => present,
    proxy_set_header => [
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto $scheme',
      'Host $http_host',
    ],
    proxy            => "http://${pulp_api_bind_address}:${pulp_api_bind_port}",
    server           => $::fqdn,
  }

  nginx::resource::location { '/':
    ensure      => present,
    try_files   => [
      '$uri @proxy_to_app',
    ],
    index_files => [],
    server      => $::fqdn,
  }

  nginx::resource::location { '@proxy_to_app':
    ensure              => present,
    proxy_set_header    => [
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto $scheme',
      'Host $http_host',
    ],
    proxy_redirect      => 'off',
    proxy               => 'http://pulp',
    proxy_next_upstream => 'http_404',
    server              => $::fqdn,
  }

}
