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
