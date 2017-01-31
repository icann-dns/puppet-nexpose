require 'spec_helper'

describe 'nexpose::ldap' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'nexpose::ldap.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:ldap_name => 'ldap',
      ldap_server: 'ldap.example.com'
      #:ldap_port => '636',
      #:ldap_ssl => true,
      #:ldap_follow_referrals => false,
      #:ldap_email_map => 'mail',
      #:ldap_login_map => 'sAMAccountName',
      #:ldap_fullname_map => 'cn',
      #:ldap_base => :undef,

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('nexpose') }
        it { is_expected.to contain_class('nexpose::ldap') }
        it do
          is_expected.to contain_augeas(
            '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap'
          ).with(
            'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
            'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
            'lens' => 'Xml.lns',
            'notify' => 'Service[nexposeconsole.rc]',
            'changes' => [
              'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
              'set Authentication/LDAPAuthenticator/#attribute/name ldap',
              'set Authentication/LDAPAuthenticator/#attribute/server ldap.example.com',
              'set Authentication/LDAPAuthenticator/#attribute/port 636',
              'set Authentication/LDAPAuthenticator/#attribute/ssl 1',
              'set Authentication/LDAPAuthenticator/#attribute/followReferrals 0',
              'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/map user.email',
              'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/name mail',
              'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/map user.login',
              'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/name sAMAccountName',
              'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/map user.fullname',
              'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/name cn'
            ]
          )
        end
        it do
          is_expected.not_to contain_augeas(
            '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap_base'
          )
        end
      end
      describe 'Change Defaults' do
        context 'ldap_name' do
          before { params.merge!(ldap_name: 'foobar') }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap'
            ).with(
              'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
              'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
              'lens' => 'Xml.lns',
              'notify' => 'Service[nexposeconsole.rc]',
              'changes' => [
                'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
                'set Authentication/LDAPAuthenticator/#attribute/name foobar',
                'set Authentication/LDAPAuthenticator/#attribute/server ldap.example.com',
                'set Authentication/LDAPAuthenticator/#attribute/port 636',
                'set Authentication/LDAPAuthenticator/#attribute/ssl 1',
                'set Authentication/LDAPAuthenticator/#attribute/followReferrals 0',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/map user.email',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/name mail',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/map user.login',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/name sAMAccountName',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/map user.fullname',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/name cn'
              ]
            )
          end
        end
        context 'ldap_server' do
          before { params.merge!(ldap_server: 'foobar.example.com') }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap'
            ).with(
              'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
              'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
              'lens' => 'Xml.lns',
              'notify' => 'Service[nexposeconsole.rc]',
              'changes' => [
                'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
                'set Authentication/LDAPAuthenticator/#attribute/name ldap',
                'set Authentication/LDAPAuthenticator/#attribute/server foobar.example.com',
                'set Authentication/LDAPAuthenticator/#attribute/port 636',
                'set Authentication/LDAPAuthenticator/#attribute/ssl 1',
                'set Authentication/LDAPAuthenticator/#attribute/followReferrals 0',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/map user.email',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/name mail',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/map user.login',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/name sAMAccountName',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/map user.fullname',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/name cn'
              ]
            )
          end
        end
        context 'ldap_port' do
          before { params.merge!(ldap_port: 1337) }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap'
            ).with(
              'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
              'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
              'lens' => 'Xml.lns',
              'notify' => 'Service[nexposeconsole.rc]',
              'changes' => [
                'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
                'set Authentication/LDAPAuthenticator/#attribute/name ldap',
                'set Authentication/LDAPAuthenticator/#attribute/server ldap.example.com',
                'set Authentication/LDAPAuthenticator/#attribute/port 1337',
                'set Authentication/LDAPAuthenticator/#attribute/ssl 1',
                'set Authentication/LDAPAuthenticator/#attribute/followReferrals 0',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/map user.email',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/name mail',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/map user.login',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/name sAMAccountName',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/map user.fullname',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/name cn'
              ]
            )
          end
        end
        context 'ldap_ssl' do
          before { params.merge!(ldap_ssl: false) }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap'
            ).with(
              'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
              'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
              'lens' => 'Xml.lns',
              'notify' => 'Service[nexposeconsole.rc]',
              'changes' => [
                'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
                'set Authentication/LDAPAuthenticator/#attribute/name ldap',
                'set Authentication/LDAPAuthenticator/#attribute/server ldap.example.com',
                'set Authentication/LDAPAuthenticator/#attribute/port 636',
                'set Authentication/LDAPAuthenticator/#attribute/ssl 0',
                'set Authentication/LDAPAuthenticator/#attribute/followReferrals 0',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/map user.email',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/name mail',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/map user.login',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/name sAMAccountName',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/map user.fullname',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/name cn'
              ]
            )
          end
        end
        context 'ldap_follow_referrals' do
          before { params.merge!(ldap_follow_referrals: true) }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap'
            ).with(
              'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
              'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
              'lens' => 'Xml.lns',
              'notify' => 'Service[nexposeconsole.rc]',
              'changes' => [
                'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
                'set Authentication/LDAPAuthenticator/#attribute/name ldap',
                'set Authentication/LDAPAuthenticator/#attribute/server ldap.example.com',
                'set Authentication/LDAPAuthenticator/#attribute/port 636',
                'set Authentication/LDAPAuthenticator/#attribute/ssl 1',
                'set Authentication/LDAPAuthenticator/#attribute/followReferrals 1',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/map user.email',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/name mail',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/map user.login',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/name sAMAccountName',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/map user.fullname',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/name cn'
              ]
            )
          end
        end
        context 'ldap_email_map' do
          before { params.merge!(ldap_email_map: 'foobar') }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap'
            ).with(
              'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
              'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
              'lens' => 'Xml.lns',
              'notify' => 'Service[nexposeconsole.rc]',
              'changes' => [
                'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
                'set Authentication/LDAPAuthenticator/#attribute/name ldap',
                'set Authentication/LDAPAuthenticator/#attribute/server ldap.example.com',
                'set Authentication/LDAPAuthenticator/#attribute/port 636',
                'set Authentication/LDAPAuthenticator/#attribute/ssl 1',
                'set Authentication/LDAPAuthenticator/#attribute/followReferrals 0',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/map user.email',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/name foobar',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/map user.login',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/name sAMAccountName',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/map user.fullname',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/name cn'
              ]
            )
          end
        end
        context 'ldap_login_map' do
          before { params.merge!(ldap_login_map: 'foobar') }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap'
            ).with(
              'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
              'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
              'lens' => 'Xml.lns',
              'notify' => 'Service[nexposeconsole.rc]',
              'changes' => [
                'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
                'set Authentication/LDAPAuthenticator/#attribute/name ldap',
                'set Authentication/LDAPAuthenticator/#attribute/server ldap.example.com',
                'set Authentication/LDAPAuthenticator/#attribute/port 636',
                'set Authentication/LDAPAuthenticator/#attribute/ssl 1',
                'set Authentication/LDAPAuthenticator/#attribute/followReferrals 0',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/map user.email',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/name mail',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/map user.login',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/name foobar',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/map user.fullname',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/name cn'
              ]
            )
          end
        end
        context 'ldap_fullname_map' do
          before { params.merge!(ldap_fullname_map: 'foobar') }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap'
            ).with(
              'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
              'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
              'lens' => 'Xml.lns',
              'notify' => 'Service[nexposeconsole.rc]',
              'changes' => [
                'set Authentication/LDAPAuthenticator/#attribute/enabled 1',
                'set Authentication/LDAPAuthenticator/#attribute/name ldap',
                'set Authentication/LDAPAuthenticator/#attribute/server ldap.example.com',
                'set Authentication/LDAPAuthenticator/#attribute/port 636',
                'set Authentication/LDAPAuthenticator/#attribute/ssl 1',
                'set Authentication/LDAPAuthenticator/#attribute/followReferrals 0',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/map user.email',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.email\']/#attribute/name mail',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/map user.login',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.login\']/#attribute/name sAMAccountName',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/map user.fullname',
                'set Authentication/LDAPAuthenticator/ldapAttribute[#attribute/map=\'user.fullname\']/#attribute/name foobar'
              ]
            )
          end
        end
        context 'ldap_base' do
          before { params.merge!(ldap_base: 'foobar') }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml_ldap_base'
            ).with(
              'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
              'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
              'lens' => 'Xml.lns',
              'notify' => 'Service[nexposeconsole.rc]',
              'changes' => [
                'set Authentication/LDAPAuthenticator/#attribute/searchBase foobar'
              ]
            )
          end
        end
      end
      describe 'check bad type' do
        context 'ldap_name' do
          before { params.merge!(ldap_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ldap_server' do
          before { params.merge!(ldap_server: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ldap_port' do
          before { params.merge!(ldap_port: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ldap_ssl' do
          before { params.merge!(ldap_ssl: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ldap_follow_referrals' do
          before { params.merge!(ldap_follow_referrals: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ldap_email_map' do
          before { params.merge!(ldap_email_map: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ldap_login_map' do
          before { params.merge!(ldap_login_map: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ldap_fullname_map' do
          before { params.merge!(ldap_fullname_map: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ldap_base' do
          before { params.merge!(ldap_base: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
