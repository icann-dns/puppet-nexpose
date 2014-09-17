Puppet::Type.newtype(:nexpose_host) do
    @doc = 'This type provides the capability to manage hosts in nexpose'

    ensurable

    def munge_boolean(value)
      case value
      when true, "true", :true
        :true
      when false, "false", :false
        :false
      else
        fail("munge_boolean only takes booleans")
      end
    end

    newparam(:host, :namevar => true) do
        desc 'the FQFN'
        newvalues(/[\w\-\.]+/)
    end

    newproperty(:operational, :boolean => true ) do
        desc "whether to monitor the host"
        newvalue(:true)
        newvalue(:false)
        munge do |value|
          @resource.munge_boolean(value)
        end
    end

    newproperty(:site ) do
        desc "site to use"
        newvalues(/\w+/)
    end
end
