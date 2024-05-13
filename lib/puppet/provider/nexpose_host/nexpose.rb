require File.expand_path(File.join(File.dirname(__FILE__), '..', 'nexpose'))
Puppet::Type.type(:nexpose_host).provide(:nexpose, parent: Puppet::Provider::Nexpose) do
  defaultfor kernel: 'Linux'
  mk_resource_methods
  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name] # rubocop:disable Lint/AssignmentInCondition
        resource.provider = prov
      end
    end
  end

  def self.instances
    results = []
    nsc = connection
    return results if nsc.nil?
    nsc.login
    nsc.list_sites.map do |site_summary|
      site = ::Nexpose::Site.load(nsc, site_summary.id)
      site.included_scan_targets[:addresses].map do |asset|
        Puppet.debug("Collecting #{asset.host}")
        result = { ensure: :present }
        result[:name] = asset.host
        result[:nexpose_site] = site.name
        result[:operational] = !site.excluded_addresses.include?(::Nexpose::HostName.new(result[:name]))
        results << new(result)
      end
    end
    results
  end

  def flush
    nsc = connection
    return if nsc.nil?
    nsc.login
    @site_name = @property_flush.key?(:nexpose_site) ? @property_flush[:nexpose_site] : @resource[:nexpose_site]
    @operational = @property_flush.key?(:operational) ? @property_flush[:operational] : @resource[:operational]
    if @property_flush[:ensure] == :absent
      nsc.list_sites.map do |site_summary|
        Puppet.debug("remove #{@resource[:name]}")
        site = ::Nexpose::Site.load(nsc, site_summary.id)
        if site.included_scan_targets[:addresses].include? ::Nexpose::HostName.new(@resource[:name])
          site.excluded_addresses[:addresses].reject! do |asset|
            asset == ::Nexpose::HostName.new(@resource[:name])
          end
          site.save(nsc)
        end
      end
    else
      site_summary = nsc.list_sites.find { |site| site.name == @site_name }
      if site_summary
        Puppet.debug("add #{@resource[:name]}")
        site = ::Nexpose::Site.load(nsc, site_summary.id)
        site.add_host(@resource[:name])
        if @operational
          Puppet.debug("enable #{@resource[:name]}")
          site.excluded_addresses.reject! do |exclude|
            exclude == ::Nexpose::HostName.new(@resource[:name])
          end
        else
          Puppet.debug("disable #{@resource[:name]}")
          site.excluded_addresses.push(::Nexpose::HostName.new(@resource[:name]))
        end
        site.save(nsc)
      else
        Puppet.warning("Unable to add #{@resource[:name]} as #{@site_name} does not exist")
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
