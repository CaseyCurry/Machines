- update /etc/network/interfaces
    iface eth1 inet static
      address 191.168.56.109
      netmask 255.255.255.0

# https://wiki.alpinelinux.org/wiki/Setting_up_nsd_DNS_server
apk update
apk upgrade
apk add nsd
printf 'server:
        ip-address: 192.168.56.109
        port: 53
        server-count: 1
        ip4-only: yes
        hide-version: yes
        identity: ""
        zonesdir: "/etc/nsd"
remote-control:
        control-enable: yes
        control-interface: 192.168.56.109
        control-port: 8952
        server-key-file: "/etc/nsd/nsd_server.key"
        server-cert-file: "/etc/nsd/nsd_server.pem"
        control-key-file: "/etc/nsd/nsd_control.key"
        control-cert-file: "/etc/nsd/nsd_control.pem"
zone:
        name: devlab
        zonefile: devlab.zone
' > /etc/nsd/nsd.conf
printf '$ORIGIN devlab.         ;
$TTL 86400                      ;

@ IN SOA ns1.devlab. admin.devlab. (
                2017091001      ; serial
                4H              ; refresh
                1H              ; retry
                3D              ; expire
                1D              ; min TTL
                )

                        NS      ns1.devlab.

luca            IN      A       192.168.56.110
server.consul   IN      A       192.168.56.110
agent1.consul   IN      A       192.168.56.111
agent2.consul   IN      A       192.168.56.112
server.nomad    IN      A       192.168.56.110
client1.nomad   IN      A       192.168.56.111
client2.nomad   IN      A       192.168.56.112
db.luca         IN      A       192.168.56.111
server.gocd     IN      A       192.168.56.100
agent1.gocd     IN      A       192.168.56.101
verdaccio       IN      A       192.168.56.103
elasticsearch   IN      A       192.168.56.102
logstash        IN      A       192.168.56.102
*               IN      A       192.168.56.109
' > /etc/nsd/devlab.zone
nsd-control-setup
nsd-checkconf /etc/nsd/nsd.conf
/etc/init.d/nsd start
rc-update add nsd
