# Class: nexpose::ldap
class nexpose::ldap (
  $ldap_name             = $::nexpose::params::ldap_name,
  $ldap_server           = $::nexpose::params::ldap_server,
  $ldap_port        = $::nexpose::params::ldap_port,
  $ldap_ssl              = $::nexpose::params::ldap_ssl,
  $ldap_base             = $::nexpose::params::ldap_base,
  $ldap_follow_referrals = $::nexpose::params::ldap_follow_referrals,
  $ldap_email_map        = $::nexpose::params::ldap_email_map,
  $ldap_login_map        = $::nexpose::params::ldap_login_map,
  $ldap_fullname_map     = $::nexpose::params::ldap_fullname_map,
) inherits nexpose::params {
  if ! $ldap_server {
    fail('nexpose::ldap you need to set ldap_server')
  }
  if ! $ldap_base {
    fail('nexpose::ldap you need to set ldap_base')
  }
  if $ldap_ssl {
    $real_ldap_ssl = 1
  } else {
    $real_ldap_ssl = 0
  }
  if $ldap_follow_referrals {
    $real_ldap_follow_referrals = 1
  } else {
    $real_ldap_follow_referrals = 0
  }
  augeas {
    '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap':
      context => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
      incl    => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
      lens    => 'Xml.lns',
      changes => [
        "set Authentication/LDAPAuthenticator/#attribute/enabled 1",
        "set Authentication/LDAPAuthenticator/#attribute/name ${ldap_name}",
        "set Authentication/LDAPAuthenticator/#attribute/server ${ldap_server}",
        "set Authentication/LDAPAuthenticator/#attribute/port ${ldap_port}",
        "set Authentication/LDAPAuthenticator/#attribute/searchBase ${ldap_base}",
        "set Authentication/LDAPAuthenticator/#attribute/ssl ${real_ldap_ssl}",
        "set Authentication/LDAPAuthenticator/#attribute/followReferrals ${real_ldap_follow_referrals}",
        "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.email']/#attribute/map user.email",
        "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.email']/#attribute/name $ldap_email_map",
        "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.login']/#attribute/map user.login",
        "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.login']/#attribute/name $ldap_login_map",
        "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.fullname']/#attribute/map user.fullname",
        "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.fullname']/#attribute/name $ldap_fullname_map",
      ],
      notify  => Service['nexposeconsole.rc'];
  }
}
