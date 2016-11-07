# == Class: nexpose
#
class nexpose (
  Tea::Port          $port                 = 3780,
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
  Tea::Fqdn          $virtualhost          = $::fqdn,
  String             $api_user             = 'nxadmin',
  String             $api_password         = 'nxpassword',
) {
  package { 'nexpose':
    ensure   =>  '0.9.8',
    provider =>  'puppet_gem',
  }
  file {
    '/opt/rapid7/nexpose/nsc/conf/httpd.xml':
      notify  => Service['nexposeconsole.rc'],
      content => template('nexpose/httpd.xml.erb');
    '/opt/rapid7/nexpose/nsc/conf/api.conf':
      content => "user=${api_user}\npassword=${api_password}\nserver=${virtualhost}\nport=${port}\n",
      mode    => '0400';
  }
  augeas {'/opt/rapid7/nexpose/nsc/conf/nsc.xml':
    context => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
    incl    => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
    lens    => 'Xml.lns',
    changes => [
      "set WebServer/#attribute/port ${port}",
      "set WebServer/#attribute/minThreads ${min_server_threads}",
      "set WebServer/#attribute/maxThreads ${max_server_threads}",
      "set WebServer/#attribute/failureLockout ${bad_login_lockout}",
      ],
    notify  => Service['nexposeconsole.rc'],
  }
  service { 'nexposeconsole.rc':
    ensure  => running,
    enable  => true,
    require => File['/opt/rapid7/nexpose/nsc/conf/httpd.xml'],
  }
  user {'nexpose':
    password => '!';
  }
  #There is a bit of a chicken egg situation with this one.  
  #if we change the api password then the api function will fail
  nexpose_user {$api_user:
    ensure    => present,
    enabled   => true,
    password  => $api_password,
    full_name => 'Puppet API User',
    role      => 'global-admin';
  }
}
