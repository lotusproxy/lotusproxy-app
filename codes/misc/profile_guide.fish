function profile_guide
    clear
    logger 0 "* Manually create a profile"
    read -P "$prefix Your profile name -> " profile
    mkdir -p $root/profile/$profile &>/dev/null
    logger 0 "Now please paste your OutBound block(v2ray) here"
    logger 0 "Remember to add \"sockopt\": {\"mark\": 255},\" or iptables won't direct your outbound"
    while true
        read -P "Node name -> " menu_layer1
        if test $menu_layer1 = ""
            logger 4 "You can`t set the node name as a blank"
        else
            nano $root/profile/$profile/$menu_layer1
            logger 0 "Do you want to add more nodes to this profile?"
            read -n1 -P "[y/N]" menu_layer1
            switch $menu_layer1
                case y Y
                case n N '*'
                    break
            end
        end
    end
end
