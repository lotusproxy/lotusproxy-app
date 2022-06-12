function flint
    logger 0 "* Initializing the main thread"
    init
    if test "$logcat" = debug
        logger 2 "set core -> $core"
        logger 2 "set transparent_proxy -> $transparent_proxy"
        logger 2 "set allow_lan.core -> $allow_lan"
        logger 2 "set redirect_port.core -> $redirect_port"
        logger 2 "set http_port.core -> $http_port"
        logger 2 "set socks_port.core -> $socks_port"
    end
    if test -x $core
    else
        logger 4 "- Core at $core is not executable/readable or it doesn't exist, abort"
        exit
    end
    if test -r $root/profile
    else
        logger 4 "- Profile diretory is not accessable, abort"
        exit
    end
    if test -r $root/last_connection
        if test (cat $root/last_connection) != ""
            if test "$transparent_proxy" = true
                redirect_proxy load
            end
            core_launch
            if test $transparent_proxy = true
                redirect_proxy unload
            end
            logger 0 "- Main thread stopped"
        else
        end
    else
        logger 3 "! Please choose a node to connect, redirecting you to configure page..."
        sleep 1
        switch_node
    end
end
