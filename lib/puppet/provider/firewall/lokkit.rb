Puppet::Type.type(:firewall).provide(:lokkit) do
    desc 'Use lokkit utility to manage iptables.'

    commands :lokkit => '/usr/sbin/lokkit'
    commands :iptables => '/sbin/iptables'

    def ensure
        iptables = File.new('/etc/sysconfig/iptables')
        denied = iptables.grep(/^-A INPUT.*--dport #{port}.*-j ACCEPT$/).empty?
        denied ? :deny : :allow
    end

    def allow
        if @resource[:port]
            lokkit '--port', @resource[:port]
        else
            lokkit '--service', @resource[:name]
        end
    end

    def deny
        iptables_new = []
        File.new('/etc/sysconfig/iptables').readlines.each do |line|
            unless line =~ /^-A INPUT.*--dport #{port}.*-j ACCEPT$/
                iptables_new << line
            end
        end
        File.new('/etc/sysconfig/iptables', 'w').write iptables_new.join
        iptables '-D', 'INPUT', '-m', 'state', '--state', 'NEW', '-m', 'tcp',
                 '-p', 'tcp', '--dport', port, '-j', 'ACCEPT'
    end

    private

    def port
        if @resource[:port]
            return @resource[:port].split(':')[0]
        end
        name = @resource[:name]
        services = File.new('/etc/services').readlines.grep /^#{name}\s/
        raise Puppet::Error, "Cannot fined #{name} service" if services.empty?
        services[0].split[1].split('/')[0]
    end
end
