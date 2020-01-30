class pulp_three::database (
  $database_host,
  $database_user,
  $database_password,
  $database_name,
){

  postgresql::server::db { $database_name:
    user     => $database_user,
    password => postgresql_password($database_user, $database_password),
    require  => Postgresql::Server::Role[$database_user],
  }

  postgresql::server::role { $database_user:
      login         => true,
      password_hash => postgresql_password($database_user, $database_password),
  }

}
