# == Class: nexpose
#
# Full description of class nexpose here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { nexpose:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class nexpose (
  $port                 = $::nexpose::params::port,
  $server_root          = $::nexpose::params::server_root,
  $doc_root             = $::nexpose::params::doc_root,
  $min_server_threads   = $::nexpose::params::min_server_threads,
  $max_server_threads   = $::nexpose::params::max_server_threads,
  $keepalive            = $::nexpose::params::keepalive,
  $socket_timeout       = $::nexpose::params::socket_timeout,
  $sc_lookup_cache_size = $::nexpose::params::sc_lookup_cache_size,
  $debug                = $::nexpose::params::debug,
  $httpd_error_strings  = $::nexpose::params::httpd_error_strings,
  $default_start_page   = $::nexpose::params::default_start_page,
  $default_login_page   = $::nexpose::params::default_login_page,
  $default_home_page    = $::nexpose::params::default_home_page,
  $default_setup_page   = $::nexpose::params::default_setup_page,
  $default_error_page   = $::nexpose::params::default_error_page,
  $first_time_config    = $::nexpose::params::first_time_config,
  $bad_login_lockout    = $::nexpose::params::bad_login_lockout,
  $admin_app_path       = $::nexpose::params::admin_app_path,
  $auth_param_username  = $::nexpose::params::auth_param_username,
  $auth_param_password  = $::nexpose::params::auth_param_password,
  $server_id_string     = $::nexpose::params::server_id_string,
  $proglet_list         = $::nexpose::params::proglet_list,
  $taglib_list          = $::nexpose::params::taglib_list,
  $virtualhost          = $::nexpose::params::virtualhost,
  $api_user             = $::nexpose::params::api_user,
  $api_password         = $::nexpose::params::api_password,
) inherits nexpose::params {
  class { 'ruby':
    version            => '1.9.3',
    set_system_default => true,
  }
  class {'ruby::dev': }
  package { 'nexpose':
    ensure   =>  'installed',
    provider =>  'gem',
  }
  file {
    '/opt/rapid7/nexpose/nsc/conf/httpd.xml':
      notify  => Service['nexposeconsole.rc'],
      content => template('nexpose/httpd.xml.erb');
    '/opt/rapid7/nexpose/nsc/conf/api.conf':
      content => "user=${api_user}\npassword=${api_password}\nserver=${virtualhost}\nport=${port}\n",
      mode    => '0400';
  }
  augeas {
    '/opt/rapid7/nexpose/nsc/conf/nsc.xml':
      context => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
      incl    => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
      lens    => 'Xml.lns',
      changes => [
        "set WebServer/#attribute/port ${port}",
        "set WebServer/#attribute/minThreads ${min_server_threads}",
        "set WebServer/#attribute/maxThreads ${max_server_threads}",
        "set WebServer/#attribute/failureLockout ${bad_login_lockout}",
        ],
      notify  => Service['nexposeconsole.rc'];
  }
  service {
    'nexposeconsole.rc':
      ensure  => running,
      enable  => true,
      require => File['/opt/rapid7/nexpose/nsc/conf/httpd.xml'];
  }
  user {'nexpose':
    password => '!';
  }
  nexpose_user {
    $api_user:
      ensure      => present,
      enabled     => true,
      password    => $api_password,
      full_name   => 'Puppet API User',
      role        => 'global-admin';
  }
}
