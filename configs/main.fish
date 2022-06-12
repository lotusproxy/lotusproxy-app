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
