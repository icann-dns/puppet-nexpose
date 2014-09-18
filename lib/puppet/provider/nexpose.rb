require 'nexpose'
include Nexpose

class Puppet::Provider::Nexpose < Puppet::Provider

  def self.get_config
    @api_file = '/opt/rapid7/nexpose/nsc/conf/api.conf'
    @conf     = { 
      'user'     => 'nxadmin',
      'password' => 'nxpassword',
      'server'   => 'localhost',
      'port'     => 443}
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
    @conf = get_config
    Connection.new(@conf['server'], @conf['user'], @conf['password'], @conf['port'])
  end

  def self.check_password(user, password)
    @conf = get_config
    nsc = Connection.new(@conf['server'], user, password, @conf['port'])
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
