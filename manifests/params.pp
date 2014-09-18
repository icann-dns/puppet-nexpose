# Class: nexpose::params
class nexpose::params {
  #web server
  $port                  = 3780
  $server_root           = '.'
  $doc_root              = 'htroot'
  $min_server_threads    = 10
  $max_server_threads    = 100
  $keepalive             = false
  $socket_timeout        = 10000
  $sc_lookup_cache_size  = 100
  $debug                 = 10
  $httpd_error_strings   = 'conf/httpErrorStrings.properties'
  $default_start_page    = '/starting.html'
  $default_login_page    = '/login.html'
  $default_home_page     = '/home.jsp'
  $default_setup_page    = '/setup.html'
  $default_error_page    = '/error.html'
  $first_time_config     = false
  $bad_login_lockout     = 4
  $admin_app_path        = '/admin/global'
  $auth_param_username   = 'nexposeccusername'
  $auth_param_password   = 'nexposeccpassword'
  $server_id_string      = 'NSC/0.6.4 (JVM)'
  $proglet_list          = 'conf/proglet.xml'
  $taglib_list           = 'conf/taglibs.xml'
  $virtualhost           = $::fqdn
  #ldap
  $ldap_name             = 'ldap'
  $ldap_server           = undef
  $ldap_port             = 636
  $ldap_ssl              = true
  $ldap_base             = undef
  $ldap_follow_referrals = true
  $ldap_email_map        = 'mail'
  $ldap_login_map        = 'sAMAccountName'
  $ldap_fullname_map     = 'cn'
  #api
  $api_user              = 'nxadmin'
  $api_password          = 'nxpassword'
}
