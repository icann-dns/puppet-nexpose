Puppet::Type.newtype(:nexpose_host) do
    @doc = 'This type provides the capability to manage hosts in nexpose'

    ensurable

    newparam(:host, :namevar => true) do
        desc 'the FQFN'
        newvalues(/[\w\-\.]+/)
    end

    newproperty(:site ) do
        desc "site to use"
        newvalues(/\w+/)
    end
end
