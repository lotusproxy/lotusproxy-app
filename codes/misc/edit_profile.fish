function edit_profile
    clear
    logger 0 "* Available profiles"
    set counter 1
    for profile in (ls $root/profile)
        logger 0 "("$counter")" $profile
        set target_profile[$counter] $profile
        set counter (math $counter+1)
    end
    echo
    read -n1 -P "$prefix >>> " menu_layer1
    if string match -qr '^[0-9]+$' $menu_layer1; and test $menu_layer1 -le $counter
        clear
        logger 0 "
* Available nodes in profile: $target_profile[$menu_layer1]"
        set counter_node 1
        for node in (ls $root/profile/$target_profile[$menu_layer1])
            logger 0 "("$counter_node")" $node
            set target_node[$counter_node] $node
            set counter_node (math $counter_node+1)
        end
        echo
        read -n1 -P "$prefix >>> " menu_layer2
        if string match -qr '^[0-9]+$' $menu_layer2; and test $menu_layer1 -le $counter_node
            nano "$root/profile/$target_profile[$menu_layer1]/$target_node[$menu_layer2]"
        else
            logger 4 "- Unexpect Input, abort"
            sleep 1
            clear
            edit_profile
        end
    else
        logger 4 "- Unexpect Input, abort"
        sleep 1
        clear
        config
    end
end
