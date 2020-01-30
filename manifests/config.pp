class pulp_three::config (
  $pulp_settings_file,
  $pulp_group,
  $secret_key,
  $content_origin_host,
  $content_origin_protocol,
  $content_origin_port,
  $database_engine,
  $database_host,
  $database_user,
  $database_password,
  $database_name,
  $redis_host,
  $redis_port,
  $redis_password,
){

  file { '/etc/pulp':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $pulp_settings_file:
    ensure  => present,
    owner   => 'root',
    group   => $pulp_group,
    mode    => '0640',
    content => epp('pulp_three/settings.py.epp', {
      'secret_key'              => $secret_key,
      'content_origin_host'     => $content_origin_host,
      'content_origin_protocol' => $content_origin_protocol,
      'content_origin_port'     => $content_origin_port,
      'database_engine'         => $database_engine,
      'database_host'           => $database_host,
      'database_user'           => $database_user,
      'database_password'       => $database_password,
      'database_name'           => $database_name,
      'redis_host'              => $redis_host,
      'redis_port'              => $redis_port,
      'redis_password'          => $redis_password,
    }),
    require => File['/etc/pulp'],
  }

}
