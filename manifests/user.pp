class pulp_three::user (
  $pulp_user,
  $pulp_user_uid,
  $pulp_user_homedir,
  $pulp_group,
  $pulp_group_gid,
){

  group { $pulp_group:
    ensure => present,
    gid    => $pulp_group_gid,
  }

  user { $pulp_user:
    ensure     => present,
    uid        => $pulp_user_uid,
    gid        => $pulp_group,
    home       => $pulp_user_homedir,
    shell      => '/sbin/nologin',
    managehome => false,
  }

}
