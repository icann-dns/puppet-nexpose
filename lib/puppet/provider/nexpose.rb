require 'nexpose'

# Nexpose class
class Puppet::Provider::Nexpose < Puppet::Provider
  def self.config
    @api_file = '/opt/rapid7/nexpose/nsc/conf/api.conf'
    @conf     = {
      'user'     => 'nxadmin',
      'password' => 'nxpassword',
      'server'   => 'localhost',
      'port'     => 443,
    }
    if File.file?(@api_file)
      File.open(@api_file, 'r') do |f|
        f.each_line do |line|
          tokens = line.strip.split('=')
          @conf[tokens[0]] = tokens[1]
        end
      end
    end
    @conf
  end

  def self.connection
    @conf = config
    conn = ::Nexpose::Connection.new(@conf['server'], @conf['user'], @conf['password'], @conf['port'])
    begin
      conn.login
      conn
    rescue ::Nexpose::AuthenticationFailed
      Puppet.warning("Nexpose: unable to login")
      nil
    end
  end

  def self.check_password(user, password)
    @conf = config
    nsc = ::Nexpose::Connection.new(@conf['server'], user, password, @conf['port'])
    begin
      nsc.login
    rescue
      false
    end
  end

  def connection
    self.class.connection
  end

  def check_password(user, password)
    self.class.check_password(user, password)
  end
end
