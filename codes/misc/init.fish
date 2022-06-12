function init
    function generate_conf
        echo "core=$root/v2core/v2ray
logcat=info
transparent_proxy=false
#inbound
allow_lan=false
redirect_port=7890
http_port=7891
socks_port=7892" >$root/main.conf
    end
    if test -r $root/main.conf
    else
        logger 3 "* Can't read or find main configure file, trying to generate it..."
        if test -d $root
            generate_conf
        else
            mkdir -p $root/profile
            mkdir $root/v2core
            generate_conf
        end
    end
end
