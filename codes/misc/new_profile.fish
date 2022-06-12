function new_profile
    clear
    logger 0 "* Add a new profile to local
(1) Manually create a profile
"
    read -n1 -P "$prefix >>> " menu_layer1
    switch $menu_layer1
        case 1
            profile_guide
            sleep 1
            clear
            new_profile
        case '*'
            logger 4 "Unexpect input, abort"
            sleep 1
            clear
            config
    end
end
