Puppet::Type.newtype(:nexpose_user) do
    @doc = 'This type provides the capability to manage hosts in nexpose'

    ensurable

    def munge_boolean(value)
      case value
      when true, 'true', :true
        :true
      when false, 'false', :false
        :false
      else
        fail("munge_boolean only takes booleans")
      end
    end

    newparam(:username, :namevar => true) do
        desc 'zabbix username'
    end

    newproperty(:password ) do
        desc 'user password'
    end

    newproperty(:full_name ) do
        desc 'users fullname'
    end

    newproperty(:email ) do
        desc 'email address'
        newvalues(/[\w\.\%\+\-]+\@[a-zA-Z\d\-\.]+/)
    end

    newproperty(:enabled ) do
        desc 'is the user enabled'
        defaultto(:true)
        newvalue(:true)
        newvalue(:false)
        munge do |value|
          @resource.munge_boolean(value)
        end
    end

    newproperty(:role ) do
        desc 'user role'
        isrequired
        newvalues(:'user',  :'system-admin', :'controls-insight-only', :'global-admin', 
                  :'security-manager', :'site-admin')
    end
end
