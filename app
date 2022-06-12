#!/usr/bin/env fish

function logger-warn
  set_color magenta
  echo "$prefix [Warn] $argv[1..-1]"
  set_color normal
end
function logger-error
  set_color red
  echo "$prefix [Error] $argv[1..-1]"
  set_color normal
end
function logger-info
  set_color normal
  echo "$prefix [Info] $argv[1..-1]"
  set_color normal
end
function logger-debug
  set_color yellow
  echo "$prefix [Debug] $argv[1..-1]"
  set_color normal
end
function logger-success
  set_color green
  echo "$prefix [Succeeded] $argv[1..-1]"
  set_color normal
end
function logger -d "a lib to print msg quickly"
switch $argv[1]
case 0
  logger-info $argv[2..-1]
case 1
  logger-success $argv[2..-1]
case 2
  logger-debug $argv[2..-1]
case 3
  logger-warn $argv[2..-1]
case 4
  logger-error $argv[2..-1]
end
end

function help_echo
 echo '
(./)app [run, config, stop, v/version, h/help]

    run: Start the proxy
        Note: Use (./)app stop to turn off the proxy 

    config: Configure details

    stop: Shutdown the proxy

    v/version: Show version
    
    h/help: Show this msg
Args
(./)app [-d/--directory=]

    -d/--directory: Set root directory for configs and profiles'
end

function size
    set size1239_calcamount $argv[1]
    if [ "$size1239_calcamount" -ge 0 ]
        set size1239_printamount (math -s2 $size1239_calcamount/1)
        set size1239_scale b
    end
    if [ "$size1239_calcamount" -ge 8 ]
        set size1239_printamount (math -s2 $size1239_calcamount/8)
        set size1239_scale B
    end
    if [ "$size1239_calcamount" -ge 8192 ]
        set size1239_printamount (math -s2 $size1239_calcamount/8192)
        set size1239_scale KB
    end
    if [ "$size1239_calcamount" -ge 8388608 ]
        set size1239_printamount (math -s2 $size1239_calcamount/8388608)
        set size1239_scale MB
    end
    if [ "$size1239_calcamount" -ge 8589934592 ]
        set size1239_printamount (math -s2 $size1239_calcamount/8589934592)
        set size1239_scale GB
    end
    if [ "$size1239_calcamount" -ge 8796093022208 ]
        set size1239_printamount (math -s2 $size1239_calcamount/8796093022208)
        set size1239_scale TB
    end
    if [ "$size1239_calcamount" -ge 9007199254741000 ]
        set size1239_printamount (math -s2 $size1239_calcamount/9007199254741000)
        set size1239_scale PB
    end
    echo $size1239_printamount $size1239_scale
end
function configure
    sed -n "/$argv[1]=/"p "$argv[2]" | sed "s/$argv[1]=//g"
end
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
            config
        case '*'
            logger 4 "Unexpect input, abort"
            sleep 1
            clear
            config
    end
end

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

function switch_node
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
            logger 0 "+ Writing to database..."
            echo "$target_profile[$menu_layer1]/$target_node[$menu_layer2]" >$root/last_connection
            logger 0 "- Done"
        else
            logger 4 "- Unexpect Input, abort"
            exit
        end
    else
        logger 4 "- Unexpect Input, abort"
        exit
    end
end

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

function core_launch
    cd (dirname $core)
    if test -r ./config.json
        rm ./config.json
    end
    echo "{
    \"log\": {
        \"loglevel\": \"$logcat\"
    },
    \"dns\": {
        \"servers\": [
            \"https://1.1.1.1/dns-query\",
            {
                \"address\": \"https://223.5.5.5/dns-query\",
                \"domains\": [
                    \"domain:googleapis.cn\",
                    \"geosite:cn\"
                ],
                \"expectIPs\": [
                    \"geoip:cn\"
                ]
            }
        ]
    },
    \"routing\": {
        \"rules\": [
            {
                \"type\": \"field\",
                \"outboundTag\": \"direct\",
                \"domain\": [
                    \"geosite:cn\"
                ]
            },
            {
                \"type\": \"field\",
                \"outboundTag\": \"direct\",
                \"ip\": [
                    \"geoip:cn\",
                    \"geoip:private\"
                ]
            },
            {
                \"type\": \"field\",
                \"inboundTag\": [
                    \"tproxy-in\"
                ],
                \"port\": 53,
                \"network\": \"udp\",
                \"outboundTag\": \"dns-out\"
            }
        ]
    },
    \"inbounds\": [
        {
            $(if test $allow_lan = false;echo \"listen\": \"127.0.0.1\",;end)
            \"port\": $redirect_port,
            \"protocol\": \"dokodemo-door\",
            \"settings\": {
                \"network\": \"tcp,udp\",
                \"followRedirect\": true
            },
            \"sniffing\": {
                \"enabled\": true,
                \"destOverride\": [
                    \"http\",
                    \"tls\"
                ]
            },
            \"tag\": \"tproxy-in\"
        },
        {
            $(if test $allow_lan = false;echo \"listen\": \"127.0.0.1\",;end)
            \"port\": $http_port,
            \"protocol\": \"http\"
        },
        {
            $(if test $allow_lan = false;echo \"listen\": \"127.0.0.1\",;end)
            \"port\": $socks_port,
            \"protocol\": \"socks\",
            \"sniffing\": {
                \"enabled\": true,
                \"metadataOnly\": false,
                \"routeOnly\": true,
                \"destOverride\": [
                    \"http\",
                    \"tls\"
                ]
            },
            \"settings\": {
                \"auth\": \"noauth\",
                \"udp\": true
            }
        }
    ],
    \"outbounds\": [
        $(cat $root/profile/$(cat $root/last_connection)),
        {
            \"tag\": \"direct\",
            \"protocol\": \"freedom\",
            \"streamSettings\": {
                \"sockopt\": {
                \"mark\": 255
              }
            }
        },
        {
            \"tag\": \"block\",
            \"protocol\": \"blackhole\"
        },
        {
            \"tag\": \"dns-out\",
            \"protocol\": \"dns\",
            \"streamSettings\": {
                \"sockopt\": {
                \"mark\": 255
              }
            }
        }
    ]
}" | $core
end

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

echo Build_Time_UTC=2022-06-12_04:03:44
set -lx prefix "[LotusProxy]"
set -lx root ~/.config/lotusproxy
argparse -i -n $prefix 'd/directory=' -- $argv
if set -q _flag_directory
    set root $_flag_directory
end
if test -e "$root/main.conf"
else
    init
end
set -lx core (configure core $root/main.conf)
set -lx logcat (configure logcat $root/main.conf)
set -lx transparent_proxy (configure transparent_proxy $root/main.conf)
set -lx allow_lan (configure allow_lan $root/main.conf)
set -lx redirect_port (configure redirect_port $root/main.conf)
set -lx http_port (configure http_port $root/main.conf)
set -lx socks_port (configure socks_port $root/main.conf)
switch $argv[1]
    case run
        flint
    case config
        config
    case stop
        killall (basename $core)
    case v version
        logger 0 'Ishikusuhana@build1'
    case h help '*'
        help_echo
end
