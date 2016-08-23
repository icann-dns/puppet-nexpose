Puppet::Type.newtype(:nexpose_site) do
    @doc = 'This type provides the capability to manage hosts in nexpose'

    ensurable

    newparam(:name, :namevar => true) do
        desc 'Name of the site'
    end

    newproperty(:scan_template) do
        desc "site to use"
        isrequired
        newvalues(:cis, :disa, :'dos-audit', :discovery, :'aggressive-discovery', :'exhaustive-audit', :'fdcc-1_2_1_0', 
                  :'full-audit', :'full-audit-without-web-spider', :'hipaa-audit', :'internet-audit', :'linux-rpm', 
                  :'microsoft-hotfix', :'pci-audit', :'pentest-audit', :'scada', :'network-audit', :'sox-audit', 
                  :'usgcb-1_2_1_0', :'web-audit')
    end
   newproperty(:description) do
     desc 'Description of the site'
   end
end
