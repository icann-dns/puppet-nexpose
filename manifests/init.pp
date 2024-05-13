# @summary module to configure nexpose
# @param port The port nunmber
# @param server_root The server root
# @param doc_root The doc root
# @param min_server_threads Min number of threads
# @param max_server_threads Max number of threads
# @param keepalive configure keep alive
# @param socket_timeout Socket timeout
# @param sc_lookup_cache_size Cache size
# @param debug Debug level
# @param httpd_error_strings Http error strings
# @param default_start_page default start page
# @param default_login_page default login page
# @param default_home_page default home page
# @param default_setup_page default setup page
# @param default_error_page default error page
# @param first_time_config set this to first time config
# @param bad_login_lockout The login lockout count
# @param admin_app_path The admin end point
# @param auth_param_username The http form param for the username
# @param auth_param_password The http form param for the password
# @param server_id_string The server ID string to use
# @param proglet_list the prog let lib file
# @param taglib_list the tag lib file
# @param virtualhost The domain name of nexpose
# @param api_user The nexpose api user
# @param api_password The nexpose api password
# @param api_email The nexpose api email
class nexpose (
  Stdlib::Port       $port                 = 3780,
  String             $server_root          = '.',
  String             $doc_root             = 'htroot',
  Integer[1,1000]    $min_server_threads   = 10,
  Integer[1,10000]   $max_server_threads   = 100,
  Boolean            $keepalive            = false,
  Integer[1,1000000] $socket_timeout       = 10000,
  Integer[1,10000]   $sc_lookup_cache_size = 100,
  Integer[1,10000]   $debug                = 10,
  String             $httpd_error_strings  = 'conf/httpErrorStrings.properties',
  String             $default_start_page   = '/starting.html',
  String             $default_login_page   = '/login.html',
  String             $default_home_page    = '/home.jsp',
  String             $default_setup_page   = '/setup.html',
  String             $default_error_page   = '/error.html',
  Boolean            $first_time_config    = false,
  Integer[1,10]      $bad_login_lockout    = 4,
  String             $admin_app_path       = '/admin/global',
  String             $auth_param_username  = 'nexposeccusername',
  String             $auth_param_password  = 'nexposeccpassword',
  String             $server_id_string     = 'NSC/0.6.4 (JVM)',
  String             $proglet_list         = 'conf/proglet.xml',
  String             $taglib_list          = 'conf/taglibs.xml',
  Stdlib::Fqdn       $virtualhost          = $facts['networking']['fqdn'],
  String             $api_user             = 'nxadmin',
  String             $api_password         = 'nxpassword',
  String             $api_email            = 'nxadmin@example.org',
) {
  package { 'rapid7_vm_console':
    ensure   => 'installed',
    provider => 'puppet_gem',
  }
  file {
    '/opt/rapid7/nexpose/nsc/conf/httpd.xml':
      notify  => Service['nexposeconsole'],
      content => template('nexpose/httpd.xml.erb');
    '/opt/rapid7/nexpose/nsc/conf/api.conf':
      content => "user=${api_user}\npassword=${api_password}\nserver=${virtualhost}\nport=${port}\n",
      mode    => '0400';
  }
  augeas { '/opt/rapid7/nexpose/nsc/conf/nsc.xml':
    context => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
    incl    => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
    lens    => 'Xml.lns',
    changes => [
      "set WebServer/#attribute/port ${port}",
      "set WebServer/#attribute/minThreads ${min_server_threads}",
      "set WebServer/#attribute/maxThreads ${max_server_threads}",
      "set WebServer/#attribute/failureLockout ${bad_login_lockout}",
      ],
    notify  => Service['nexposeconsole'],
  }
  service { 'nexposeconsole':
    ensure  => running,
    enable  => true,
    require => File['/opt/rapid7/nexpose/nsc/conf/httpd.xml'],
  }
  user { 'nexpose':
    password => '!';
  }
  # There is a bit of a chicken egg situation with this one.  
  # if we change the api password then the api function will fail
  nexpose_user { $api_user:
    ensure    => present,
    enabled   => true,
    password  => $api_password,
    email     => $api_email,
    full_name => 'Puppet API User',
    role      => 'global-admin';
  }
}
