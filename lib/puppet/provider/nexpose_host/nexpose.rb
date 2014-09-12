require 'nexpose'
include Nexpose
Puppet::Type.type(:nexpose_host).provide(:nexpose) do

  defaultfor :kernel => 'Linux'
  mk_resource_methods
  def initialize(value={})
    super(value)
    @property_flush = {}
  end
  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.instances
    nsc = Connection.new('127.0.0.1', 'nxadmin', 'nxpassword', 443)
    nsc.login 
    nsc.devices.collect do |device|
      result = { :ensure => :present }
      result[:name] = device.address
      result[:siteid] = device.id
      new(result)
    end
    nsc.logout 
  end

  def siteid=(value)
    @property_flush[:siteid] = value
  end

  def flush
    nsc = Connection.new('127.0.0.1', 'nxadmin', 'nxpassword', 443)
    nsc.login
    @siteid =  @property_flush.key?(:siteid)? @property_flush[:siteid] : @resource[:siteid]
    if @property_flush[:ensure] == :absent
      site = Site.load(nsc, @siteid)
      site.add_host(@resource[:name])
      site.save
    else
      Puppet.debug('not implmented')
    end
    nsc.logout
  end
  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end

end
