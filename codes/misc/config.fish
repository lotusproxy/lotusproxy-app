function config
    init
    clear
    logger 0 "Configure Menu
(1) Create a new profile
(2) Remove a profile
(3) Modify basic configure file
(4) Modify a node in profile
(5) Switch node to connect
(6) Exit
"
    read -n1 -P "$prefix >>> " menu_layer1
    switch $menu_layer1
        case 1
            new_profile
            sleep 1
            clear
            config
        case 2
            remove_profile
            sleep 1
            clear
            config
        case 3
            nano ~/.config/lotusproxy/main.conf
            sleep 1
            clear
            config
        case 4
            edit_profile
            sleep 1
            clear
            config
        case 5
            switch_node
        case 6
            exit
        case '*'
            logger 4 "Unexpect input, abort"
            sleep 1
            clear
            config
    end
end
