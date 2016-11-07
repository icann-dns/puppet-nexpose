# Class: nexpose::ldap
class nexpose::ldap (
  String           $ldap_name             = 'ldap',
  Tea::Host        $ldap_server           = undef,
  Tea::Port        $ldap_port             = 636,
  Boolean          $ldap_ssl              = true,
  Boolean          $ldap_follow_referrals = false,
  String           $ldap_email_map        = 'mail',
  String           $ldap_login_map        = 'sAMAccountName',
  String           $ldap_fullname_map     = 'cn',
  Optional[String] $ldap_base             = undef,
) {
  include ::nexpose
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
  augeas {'/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap':
    context => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
    incl    => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
    lens    => 'Xml.lns',
    notify  => Service['nexposeconsole.rc'],
    changes => [
      'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
      "set Authentication/LDAPAuthenticator/#attribute/name ${ldap_name}",
      "set Authentication/LDAPAuthenticator/#attribute/server ${ldap_server}",
      "set Authentication/LDAPAuthenticator/#attribute/port ${ldap_port}",
      "set Authentication/LDAPAuthenticator/#attribute/ssl ${real_ldap_ssl}",
      "set Authentication/LDAPAuthenticator/#attribute/followReferrals ${real_ldap_follow_referrals}",
      "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.email']/#attribute/map user.email",
      "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.email']/#attribute/name ${ldap_email_map}",
      "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.login']/#attribute/map user.login",
      "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.login']/#attribute/name ${ldap_login_map}",
      "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.fullname']/#attribute/map user.fullname",
      "set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map='user.fullname']/#attribute/name ${ldap_fullname_map}",
      ],
  }
  if $ldap_base {
    augeas {'/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap_base':
      context => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
      incl    => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
      lens    => 'Xml.lns',
      notify  => Service['nexposeconsole.rc'],
      changes => [ "set Authentication/LDAPAuthenticator/#attribute/searchBase ${ldap_base}" ],
    }
  }
}
