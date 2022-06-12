function redirect_proxy
    switch $argv[1]
        case load
            if test (id -u) = 0
                logger 0 "* Applying iptable rules to enable transparent proxy"
                iptables -t nat -N lotusproxy &>/dev/null
                iptables -t nat -A lotusproxy -d 0.0.0.0/8 -j RETURN &>/dev/null
                iptables -t nat -A lotusproxy -d 127.0.0.0/8 -j RETURN &>/dev/null
                iptables -t nat -A lotusproxy -d 10.0.0.0/8 -j RETURN &>/dev/null
                iptables -t nat -A lotusproxy -d 169.254.0.0/16 -j RETURN &>/dev/null
                iptables -t nat -A lotusproxy -d 172.16.0.0/12 -j RETURN &>/dev/null
                iptables -t nat -A lotusproxy -d 192.168.0.0/16 -j RETURN &>/dev/null
                iptables -t nat -A lotusproxy -d 224.0.0.0/4 -j RETURN &>/dev/null
                iptables -t nat -A lotusproxy -d 240.0.0.0/4 -j RETURN &>/dev/null
                iptables -t nat -A lotusproxy -p tcp -j RETURN -m mark --mark 0xff &>/dev/null
                iptables -t nat -A lotusproxy -p tcp -j REDIRECT --to-ports $redirect_port &>/dev/null
                iptables -t nat -A lotusproxy -p udp -j RETURN -m mark --mark 0xff &>/dev/null
                iptables -t nat -A lotusproxy -p udp --dport 53 -j REDIRECT --to-ports $redirect_port &>/dev/null
                iptables -t nat -A OUTPUT -p tcp -j lotusproxy &>/dev/null
                logger 0 "+ Iptable rules applied"
            else
                logger 4 "- Transparent Proxy is enabled in configure file, please run with root user"
                exit
            end
        case unload
            if test (id -u) = 0
                logger 0 "* Removing iptable rules to stop transparent proxy"
                iptables -t nat -D OUTPUT -p tcp -j lotusproxy &>/dev/null
                iptables -t nat -F lotusproxy &>/dev/null
                iptables -t nat -X lotusproxy &>/dev/null
                logger 0 "+ Iptable rules removed"
            else
                logger 4 "- Transparent Proxy is enabled in configure file, please run with root user"
                exit
            end
        case '*'
            logger "Unexpect input, abort"
            exit
    end

end
