function remove_profile
    clear
    logger 3 "! Remove a profile will delete all nodes in it, be careful when operating"
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
        logger 3 "! Are you sure that you want to remove the whole profile?![y/N]"
        read -n1 -P "$prefix >>> " menu_layer2
        switch $menu_layer2
            case y Y
                logger 0 "+ Removing the whole profile $target_profile[$menu_layer1]"
                if rm -rf "$root/profile/$target_profile[$menu_layer1]"
                    logger 1 "- Profile $target_profile[$menu_layer1] removed"
                else
                    logger 4 "- Unable to remove the profile"
                end
            case '*'
                logger 4 "- Unexpect Input, abort"
                sleep 1
                clear
                remove_profile
        end
    else
        logger 4 "- Unexpect Input, abort"
        sleep 1
        clear
        config
    end
end
