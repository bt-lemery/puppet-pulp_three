class pulp_three::packages (
  $pulp_plugins,
){

  $_pulp_prerequisite_packages = [
    'python-contextlib2',
    'postgresql-devel',
    'gcc',
    'make',
    'git',
  ]

  package { $_pulp_prerequisite_packages:
    ensure => present,
  }

  if 'pulp_rpm' in $pulp_plugins {
    $_pulp_rpm_packages = [
      'cmake',
      'bzip2-devel',
      'expat-devel',
      'file-devel',
      'glib2-devel',
      'libcurl-devel',
      'libmodulemd2-devel',
      'ninja-build',
      'libxml2-devel',
      'python36-gobject',
      'rpm-devel',
      'openssl-devel',
      'sqlite-devel',
      'xz-devel',
      'zchunk-devel',
      'zlib-devel',
      'cairo-gobject-devel',
      'gobject-introspection-devel',
    ]

    package { $_pulp_rpm_packages:
      ensure => present,
    }
  }

}
