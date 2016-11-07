require 'spec_helper'

describe 'nexpose' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'nexpose.example.com' }

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
      #:port => 3780,
      #:server_root => ".",
      #:doc_root => "htroot",
      #:min_server_threads => "10",
      #:max_server_threads => "100",
      #:keepalive => false,
      #:socket_timeout => "10000",
      #:sc_lookup_cache_size => "100",
      #:debug => "10",
      #:httpd_error_strings => "conf/httpErrorStrings.properties",
      #:default_start_page => "/starting.html",
      #:default_login_page => "/login.html",
      #:default_home_page => "/home.jsp",
      #:default_setup_page => "/setup.html",
      #:default_error_page => "/error.html",
      #:first_time_config => false,
      #:bad_login_lockout => "4",
      #:admin_app_path => "/admin/global",
      #:auth_param_username => "nexposeccusername",
      #:auth_param_password => "nexposeccpassword",
      #:server_id_string => "NSC/0.6.4 (JVM)",
      #:proglet_list => "conf/proglet.xml",
      #:taglib_list => "conf/taglibs.xml",
      #:virtualhost => "$::fqdn",
      #:api_user => "nxadmin",
      #:api_password => "nxpassword",

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
        it { is_expected.to contain_user('nexpose').with_password('!') }
        it do
          is_expected.to contain_package('nexpose').with(
            'ensure' => '0.9.8',
            'provider' => 'puppetserver_gem',
          )
        end
        it do
          is_expected.to contain_file('/opt/rapid7/nexpose/nsc/conf/httpd.xml').with(
            'notify' => 'Service[nexposeconsole.rc]',
          ).with_content(
            %r{port\s+=\s+"3780"}
          ).with_content(
            %r{serverRoot\s+=\s+"\."}
          ).with_content(
            %r{docRoot\s+=\s+"htroot"}
          ).with_content(
            %r{min-server-threads\s+=\s+"10"}
          ).with_content(
            %r{max-server-threads\s+=\s+"100"}
          ).with_content(
            %r{keepalive\s+=\s+"false"}
          ).with_content(
            %r{socket-timeout\s+=\s+"10000"}
          ).with_content(
            %r{sc-lookup-cache-size\s+=\s+"100"}
          ).with_content(
            %r{debug\s+=\s+"10"}
          ).with_content(
            %r{httpd-error-strings\s+=\s+"conf/httpErrorStrings\.properties"}
          ).with_content(
            %r{default-start-page\s+=\s+"/starting\.html"}
          ).with_content(
            %r{default-login-page\s+=\s+"/login\.html"}
          ).with_content(
            %r{default-home-page\s+=\s+"/home\.jsp"}
          ).with_content(
            %r{default-setup-page\s+=\s+"/setup\.html"}
          ).with_content(
            %r{default-error-page\s+=\s+"/error\.html"}
          ).with_content(
            %r{first-time-config\s+=\s+"false"}
          ).with_content(
            %r{bad-login-lockout\s+=\s+"4"}
          ).with_content(
            %r{admin-app-path\s+=\s+"/admin/global"}
          ).with_content(
            %r{auth-param-username\s+=\s+"nexposeccusername"}
          ).with_content(
            %r{auth-param-password\s+=\s+"nexposeccpassword"}
          ).with_content(
            %r{server-id-string\s+=\s+"NSC/0\.6\.4 \(JVM\)"}
          ).with_content(
            %r{proglet-list\s+=\s+"conf/proglet\.xml"}
          ).with_content(
            %r{taglib-list\s+=\s+"conf/taglibs\.xml"}
          )
        end
        it do
          is_expected.to contain_file('/opt/rapid7/nexpose/nsc/conf/api.conf').with(
            'mode' => '0400',
          ).with_content(
            "user=nxadmin\npassword=nxpassword\nserver=foo.example.com\nport=3780\n",
          )
        end
        it do
          is_expected.to contain_augeas('/opt/rapid7/nexpose/nsc/conf/nsc.xml').with(
            'context' => '/files/opt/rapid7/nexpose/nsc/conf/nsc.xml/NeXposeSecurityConsole',
            'incl' => '/opt/rapid7/nexpose/nsc/conf/nsc.xml',
            'lens' => 'Xml.lns',
            'changes' => [
              'set WebServer/#attribute/port 3780',
              'set WebServer/#attribute/minThreads 10',
              'set WebServer/#attribute/maxThreads 100',
              'set WebServer/#attribute/failureLockout 4'
            ],
            'notify' => 'Service[nexposeconsole.rc]',
          )
        end
        it do
          is_expected.to contain_service('nexposeconsole.rc').with(
            'ensure' => 'running',
            'enable' => true,
            'require' => 'File[/opt/rapid7/nexpose/nsc/conf/httpd.xml]',
          )
        end
        it do
          is_expected.to contain_nexpose_user('nxadmin').with(
            'ensure' => 'present',
            'enabled' => true,
            'password' => 'nxpassword',
            'full_name' => 'Puppet API User',
            'role' => 'global-admin',
          )
        end
      end
      describe 'Change Defaults' do
        context 'port' do
          before { params.merge!(port: 1337) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{port\s+=\s+"1337"}
            )
          end
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml'
            ).with(
              'changes' => [
                'set WebServer/#attribute/port 1337',
                'set WebServer/#attribute/minThreads 10',
                'set WebServer/#attribute/maxThreads 100',
                'set WebServer/#attribute/failureLockout 4'
              ]
            )
          end
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/api.conf'
            ).with_content(
              "user=nxadmin\npassword=nxpassword\nserver=foo.example.com\nport=1337\n",
            )
          end
        end
        context 'server_root' do
          before { params.merge!(server_root: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{serverRoot\s+=\s+"foobar"}
            )
          end
        end
        context 'doc_root' do
          before { params.merge!(doc_root: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{docRoot\s+=\s+"foobar"}
            )
          end
        end
        context 'min_server_threads' do
          before { params.merge!(min_server_threads: 99) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{min-server-threads\s+=\s+"99"}
            )
          end
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml'
            ).with(
              'changes' => [
                'set WebServer/#attribute/port 3780',
                'set WebServer/#attribute/minThreads 99',
                'set WebServer/#attribute/maxThreads 100',
                'set WebServer/#attribute/failureLockout 4'
              ]
            )
          end
        end
        context 'max_server_threads' do
          before { params.merge!(max_server_threads: 1337) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{max-server-threads\s+=\s+"1337"}
            )
          end
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml'
            ).with(
              'changes' => [
                'set WebServer/#attribute/port 3780',
                'set WebServer/#attribute/minThreads 10',
                'set WebServer/#attribute/maxThreads 1337',
                'set WebServer/#attribute/failureLockout 4'
              ]
            )
          end
        end
        context 'keepalive' do
          before { params.merge!(keepalive: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{keepalive\s+=\s+"true"}
            )
          end
        end
        context 'socket_timeout' do
          before { params.merge!(socket_timeout: 1337) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{socket-timeout\s+=\s+"1337"}
            )
          end
        end
        context 'sc_lookup_cache_size' do
          before { params.merge!(sc_lookup_cache_size: 1337) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{sc-lookup-cache-size\s+=\s+"1337"}
            )
          end
        end
        context 'debug' do
          before { params.merge!(debug: 1337) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{debug\s+=\s+"1337"}
            )
          end
        end
        context 'httpd_error_strings' do
          before { params.merge!(httpd_error_strings: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{httpd-error-strings\s+=\s+"foobar"}
            )
          end
        end
        context 'default_start_page' do
          before { params.merge!(default_start_page: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{default-start-page\s+=\s+"/foobar"}
            )
          end
        end
        context 'default_login_page' do
          before { params.merge!(default_login_page: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{default-login-page\s+=\s+"/foobar"}
            )
          end
        end
        context 'default_home_page' do
          before { params.merge!(default_home_page: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{default-home-page\s+=\s+"/foobar"}
            )
          end
        end
        context 'default_setup_page' do
          before { params.merge!(default_setup_page: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{default-setup-page\s+=\s+"/foobar"}
            )
          end
        end
        context 'default_error_page' do
          before { params.merge!(default_error_page: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{default-error-page\s+=\s+"/foobar"}
            )
          end
        end
        context 'first_time_config' do
          before { params.merge!(first_time_config: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{first-time-config\s+=\s+"true"}
            )
          end
        end
        context 'bad_login_lockout' do
          before { params.merge!(bad_login_lockout: 9) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{bad-login-lockout\s+=\s+"9"}
            )
          end
          it do
            is_expected.to contain_augeas(
              '/opt/rapid7/nexpose/nsc/conf/nsc.xml'
            ).with(
              'changes' => [
                'set WebServer/#attribute/port 3780',
                'set WebServer/#attribute/minThreads 10',
                'set WebServer/#attribute/maxThreads 100',
                'set WebServer/#attribute/failureLockout 9'
              ]
            )
          end
        end
        context 'admin_app_path' do
          before { params.merge!(admin_app_path: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{admin-app-path\s+=\s+"/foobar"}
            )
          end
        end
        context 'auth_param_username' do
          before { params.merge!(auth_param_username: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{auth-param-username\s+=\s+"foobar"}
            )
          end
        end
        context 'auth_param_password' do
          before { params.merge!(auth_param_password: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{auth-param-password\s+=\s+"foobar"}
            )
          end
        end
        context 'server_id_string' do
          before { params.merge!(server_id_string: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{server-id-string\s+=\s+"foobar"}
            )
          end
        end
        context 'proglet_list' do
          before { params.merge!(proglet_list: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{proglet-list\s+=\s+"foobar"}
            )
          end
        end
        context 'taglib_list' do
          before { params.merge!(taglib_list: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/httpd.xml'
            ).with_content(
              %r{taglib-list\s+=\s+"foobar"}
            )
          end
        end
        context 'virtualhost' do
          before { params.merge!(virtualhost: 'foobar.example.com') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/api.conf'
            ).with_content(
              "user=nxadmin\npassword=nxpassword\nserver=foobar.example.com\nport=3780\n",
            )
          end
        end
        context 'api_user' do
          before { params.merge!(api_user: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/api.conf'
            ).with_content(
              "user=foobar\npassword=nxpassword\nserver=foo.example.com\nport=3780\n",
            )
          end
          it do
            is_expected.to contain_nexpose_user('foobar').with(
              'ensure' => 'present',
              'enabled' => true,
              'password' => 'nxpassword',
              'full_name' => 'Puppet API User',
              'role' => 'global-admin',
            )
          end
        end
        context 'api_password' do
          before { params.merge!(api_password: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/opt/rapid7/nexpose/nsc/conf/api.conf'
            ).with_content(
              "user=nxadmin\npassword=foobar\nserver=foo.example.com\nport=3780\n",
            )
          end
          it do
            is_expected.to contain_nexpose_user('nxadmin').with(
              'ensure' => 'present',
              'enabled' => true,
              'password' => 'foobar',
              'full_name' => 'Puppet API User',
              'role' => 'global-admin',
            )
          end
        end
      end
      describe 'check bad type' do
        context 'port' do
          before { params.merge!(port: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'server_root' do
          before { params.merge!(server_root: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'doc_root' do
          before { params.merge!(doc_root: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'min_server_threads' do
          before { params.merge!(min_server_threads: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'max_server_threads' do
          before { params.merge!(max_server_threads: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'keepalive' do
          before { params.merge!(keepalive: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'socket_timeout' do
          before { params.merge!(socket_timeout: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'sc_lookup_cache_size' do
          before { params.merge!(sc_lookup_cache_size: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'debug' do
          before { params.merge!(debug: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'httpd_error_strings' do
          before { params.merge!(httpd_error_strings: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_start_page' do
          before { params.merge!(default_start_page: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_login_page' do
          before { params.merge!(default_login_page: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_home_page' do
          before { params.merge!(default_home_page: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_setup_page' do
          before { params.merge!(default_setup_page: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_error_page' do
          before { params.merge!(default_error_page: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'first_time_config' do
          before { params.merge!(first_time_config: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'bad_login_lockout' do
          before { params.merge!(bad_login_lockout: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'admin_app_path' do
          before { params.merge!(admin_app_path: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'auth_param_username' do
          before { params.merge!(auth_param_username: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'auth_param_password' do
          before { params.merge!(auth_param_password: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'server_id_string' do
          before { params.merge!(server_id_string: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'proglet_list' do
          before { params.merge!(proglet_list: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'taglib_list' do
          before { params.merge!(taglib_list: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'virtualhost' do
          before { params.merge!(virtualhost: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'api_user' do
          before { params.merge!(api_user: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'api_password' do
          before { params.merge!(api_password: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
