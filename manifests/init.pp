# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include pulp_three
#
# @param install_prereqs
#   Specifies whether to allow this module to install any rpms required by your chosen pulp plugins.
#
# @param pulp_plugins
#   Array of pulp plugins to install in addition to 'pulpcore'.
#
# @param manage_python
#   Specifies whether to allow this module to install a Python interpreter from SCL.
#
# @param python_version
#   Python version to install from SCL.  Defaults to 'rh-python36'.
#
# @param proxy
#   Proxy to use when installing pip packages/ruby gems.  Defaults to none.
#
# @param manage_user
#   Whether this module should create a user to run pulp.  Defaults to false.
#
# @param pulp_user
#   Name of pulp user.  Defaults to 'pulp'.
#
# @param pulp_user_uid
#   UID for pulp user. Defaults to 500.
#
# @param pulp_user_homedir
#   Pulp user homedir.  Defaults to pulp_media_root.
#
# @param pulp_group
#   Pulp group.  Defaults to 'pulp'.
#
# @param pulp_group_gid
#   GID for pulp group.  Defaults to 500.
#
# @param pulp_media_root
#   Pulp media root.  Defaults to '/var/lib/pulp'.
#
# @param pulp_working_dir
#   Pulp working directory.  Defaults to '/var/lib/pulp/tmp'.
#
# @param pulp_install_dir
#   Where to install the pulp venv.  Defaults to '/var/lib/pulp/pulpvenv'.
#
# @param secret_key
#   Secret key for Django.  Defaults to 'secret'.
#
# @param content_origin_host
#   Content origin hostname for Django.  Defaults to FQDN.
#
# @param content_origin_protocol
#   Content origin protocol for Django.  Defaults to 'http'.
#
# @param content_origin_port
#   Content origin port for Django.  Defaults to 24816.
#
# @param database_engine
#   Database engine string for Django.  Defaults to 'django.db.backends.postgresql_psycopg2'.
#
# @param database_host
#   Database host for Django.  Defaults to 'localhost'.
#
# @param database_user
#   Database user for Django.  Defaults to 'pulp'.
#
# @param database_password
#   Database password for Django.  Defaults to 'pulp'.
#
# @param database_name
#   Database name for Django.  Defaults to 'pulp'.
#
# @param redis_host
#   Redis host for Pulp workers.  Defaults to 'localhost'.
#
# @param redis_port
#   Redis port for Pulp workers.  Defaults to 6379.
#
# @param redis_password
#   Redis password for Pulp workers.  Defaults to 'redis'.
#
# @param manage_nginx
#   Whether this module should install the nginx webserver and configure it as a reverse proxy to the pulp services.  Defaults to false.
#
# @param nginx_package_name
#   Which version of the nginx package to install.  Defaults to 'nginx'.
#
# @param pulp_content_bind_address
#   Address of pulp content service.  Defaults to '127.0.0.1'
#
#  @param pulp_content_bind_port
#    Port of pulp content service.  Defaults to 24816.
#
#  @param pulp_api_bind_address
#    Address of pulp api service.  Defaults to '127.0.0.1'
#
#  @param pulp_api_bind_port
#    Port of pulp api service.  Defaults to 24817.
#
#  @param pulp_settings_file
#    File location for Pulp config.  Defaults to '/etc/pulp/settings.py'.
#
#  @param pulp_admin_password
#    Password for Django admin account.  Defaults to 'admin'.
#
#  @param pulp_worker_ids
#    Names for pulp worker processes.  By default this module will create two worker processes called 'pulpcore-worker@1' and 'pulpcore-worker@2'.
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
  String $pulp_working_dir,
  String $pulp_install_dir,
  String $secret_key,
  String $content_origin_host,
  String $content_origin_protocol,
  Integer $content_origin_port,
  String $database_engine,
  String $database_host,
  String $database_user,
  String $database_password,
  String $database_name,
  String $redis_host,
  Integer $redis_port,
  String $redis_password,
  Boolean $manage_nginx,
  String $nginx_package_name,
  String $pulp_content_bind_address,
  Integer $pulp_content_bind_port,
  String $pulp_api_bind_address,
  Integer $pulp_api_bind_port,
  String $pulp_settings_file,
  String $pulp_admin_password,
  Array[String] $pulp_worker_ids,
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
    contain 'pulp_three::user'
  }

  if ! empty(proxy) {
    $proxy_server = $proxy
  } else {
    $proxy_server = undef
  }

  class { 'pulp_three::install':
    pulp_media_root  => $pulp_media_root,
    pulp_working_dir => $pulp_working_dir,
    pulp_install_dir => $pulp_install_dir,
    proxy_server     => $proxy_server,
    pulp_user        => $pulp_user,
    pulp_group       => $pulp_group,
    pulp_plugins     => $pulp_plugins,
  }

  if empty($content_origin_host) {
    $content_origin_host_final = $::fqdn
  } else {
    $content_origin_host_final = $content_origin_host
  }

  class { 'pulp_three::config':
    pulp_settings_file      => $pulp_settings_file,
    pulp_group              => $pulp_group,
    secret_key              => $secret_key,
    content_origin_host     => $content_origin_host_final,
    content_origin_protocol => $content_origin_protocol,
    content_origin_port     => $content_origin_port,
    database_engine         => $database_engine,
    database_host           => $database_host,
    database_user           => $database_user,
    database_password       => $database_password,
    database_name           => $database_name,
    redis_host              => $redis_host,
    redis_port              => $redis_port,
    redis_password          => $redis_password,
  }

  if $manage_nginx {
    class { 'pulp_three::nginx':
      nginx_package_name        => $nginx_package_name,
      pulp_install_dir          => $pulp_install_dir,
      pulp_content_bind_address => $pulp_content_bind_address,
      pulp_content_bind_port    => $pulp_content_bind_port,
      pulp_api_bind_address     => $pulp_api_bind_address,
      pulp_api_bind_port        => $pulp_api_bind_port,
    }
    contain 'pulp_three::nginx'
  }

  class { 'pulp_three::migrations':
    pulp_settings_file  => $pulp_settings_file,
    pulp_install_dir    => $pulp_install_dir,
    pulp_admin_password => $pulp_admin_password,
  }
  contain 'pulp_three::migrations'

  class { 'pulp_three::service':
    pulp_settings_file        => $pulp_settings_file,
    pulp_install_dir          => $pulp_install_dir,
    pulp_user                 => $pulp_user,
    pulp_group                => $pulp_group,
    pulp_content_bind_address => $pulp_content_bind_address,
    pulp_content_bind_port    => $pulp_content_bind_port,
    pulp_api_bind_address     => $pulp_api_bind_address,
    pulp_api_bind_port        => $pulp_api_bind_port,
    pulp_worker_ids           => $pulp_worker_ids,
  }
  contain 'pulp_three::service'

  class { 'pulp_three::gems':
    pulp_plugins        => $pulp_plugins,
    pulp_admin_password => $pulp_admin_password,
    proxy_server        => $proxy_server,
  }
  contain 'pulp_three::gems'

}
