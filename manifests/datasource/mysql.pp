# @summary Manage MySQL datasource
#
# @api private
#
# @param jar_source
#   Path to MySQL connector jar file.
#
class keycloak::datasource::mysql (
  $jar_source = '/usr/share/java/mysql-connector-java.jar',
) {
  assert_private()

  $module_dir = "${keycloak::install_dir}/keycloak-${keycloak::version}/modules/system/layers/keycloak/com/mysql/jdbc/main"

  include ::mysql::bindings
  include ::mysql::bindings::java

  exec { "mkdir -p ${module_dir}":
    path    => '/usr/bin:/bin',
    creates => $module_dir,
    user    => $keycloak::user,
    group   => $keycloak::group,
  }
  -> file { $module_dir:
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0755',
  }
  file { "${$module_dir}/mysql-connector-java.jar":
    ensure  => 'link',
    target  => $jar_source,
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0644',
    require => Class['::mysql::bindings::java'],
  }
  file { "${$module_dir}/module.xml":
    ensure => 'file',
    source => 'puppet:///modules/keycloak/database/mysql/module.xml',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0644',
  }

  if $keycloak::manage_datasource {
    mysql::db { $keycloak::datasource_dbname:
      user     => $keycloak::datasource_username,
      password => $keycloak::datasource_password,
      host     => $keycloak::db_host,
      grant    => 'ALL',
    }
  }

}
