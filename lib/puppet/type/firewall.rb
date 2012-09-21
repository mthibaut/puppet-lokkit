# High level iptables management.
#
# Properties:
#
# - +ensure+    Is specified port allowed or denied. Supported values: +allow+, +deny+.
#
# Parameters:
#
# - +name+      Network service name. Value from `lokkit --list-services` list.
# - +port+      If there is not predefined serivce name, port might be specified directly: <port>:<protocol>
#
Puppet::Type.newtype(:firewall) do
    @doc = ''

    newproperty(:ensure) do
        newvalue(:allow) do
            provider.allow
        end

        newvalue(:deny) do
            provider.deny
        end

        defaultto :deny
    end

    newparam(:name, :isnamevar => true) do
    end

    newparam(:port) do
    end
end
