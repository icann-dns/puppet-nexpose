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
    results = Array.new
    nsc = Connection.new('127.0.0.1', 'nxadmin', 'nxpassword', 443)
    nsc.login 
    nsc.list_sites.collect do |site|
      Site.load(nsc, site.id).assets.collect do |asset|
        Puppet.debug("Collecting #{asset.host}")
        result = { :ensure => :present }
        result[:name] = asset.host
        result[:site] = site.name
        results << new(result)
      end
    end
    results
  end

  def site=(value)
    @property_flush[:site] = value
  end

  def flush
    nsc = Connection.new('127.0.0.1', 'nxadmin', 'nxpassword', 443)
    nsc.login
    @site_name =  @property_flush.key?(:site)? @property_flush[:site] : @resource[:site]
    if @property_flush[:ensure] == :absent
      nsc.list_sites.collect do |site_summary| 
        Puppet.debug("remove #{@resource[:name]}")
        site = Site.load(nsc, site_summary.id)
        if site.assets.include? HostName.new(@resource[:name])
          site.assets = site.assets.reject { |asset| asset == HostName.new(@resource[:name]) }
          site.save(nsc)
        end
      end
    else
      site_summary = nsc.list_sites.find { |site| site.name == @site_name } 
      if site_summary
        Puppet.debug("add #{@resource[:name]}")
        site = Site.load(nsc, site_summary.id)
        site.add_host(@resource[:name])
        site.save(nsc)
      else
        Puppet.warn("Unable to add @resource[:name] as @site_name dose not exist")
      end
    end
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
