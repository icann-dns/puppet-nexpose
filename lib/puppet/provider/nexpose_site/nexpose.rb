require File.expand_path(File.join(File.dirname(__FILE__), '..', 'nexpose'))
Puppet::Type.type(:nexpose_site).provide(:nexpose, :parent => Puppet::Provider::Nexpose ) do

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
    nsc = connection
    nsc.login 
    nsc.sites.collect do |site_summary|
      site = Site.load(nsc, site_summary.id)
      Puppet.debug("Collecting #{site.name}")
      result = { :ensure => :present }
      result[:name] = site.name
      result[:description] = site.description
      result[:scan_template] = site.scan_template
      new(result)
    end
  end

  def description=(value)
    @property_flush[:description] = value
  end

  def scan_template=(value)
    @property_flush[:scan_template] = value
  end

  def flush
    @description =  @property_flush.key?(:description)? @property_flush[:description] : @resource[:description]
    @scan_template =  @property_flush.key?(:scan_template)? @property_flush[:scan_template] : @resource[:scan_template]
    nsc = connection
    nsc.login
    site_summary = nsc.list_sites.find { |site| site.name == @resource[:name] }
    if @property_flush[:ensure] == :absent
      if site_summary 
        Puppet.debug("delete #{@resource[:name]}")
        nsc.delete_site(site_summary.id)
      end
    else
      if site_summary 
        Puppet.debug("update #{@resource[:name]}")
        site = Site.load(nsc, site_summary.id)
        site.scan_template = @scan_template
        site.description   = @description
        site.save(nsc)
      else
        Puppet.debug("add #{@resource[:name]}")
        site = Site.new(@resource[:name], @scan_template)
        site.description = @description
        site.save(nsc)
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
