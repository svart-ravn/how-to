## setup custom haproxy check


#### haproxy.cfg
```
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

listen  MLI 0.0.0.0:3307
        mode tcp
        timeout client  10800s
        timeout server  10800s
        balance roundrobin
        option tcpka

        server 192.168.174.165 192.168.174.165:3306 check weight 100
        server 192.168.174.158 192.168.174.158:3306 check agent-check agent-port 2345 weight 100
```
where agent-check/agent-port tell which port will tell us something about service availability


#### simple socket service (socat required)
```
#!/bin/bash

mysql_config=/root/.my.cnf
export mysql_cmd="mysql --defaults-file=$mysql_config"
port=$1


function health_check() {
   conn_cnt=$($mysql_cmd -e "select * from information_schema.processlist" | wc -l)
   if [ $conn_cnt -ge 100 ]; then
     echo "up 5%"
   elif [ $conn_cnt -ge 50 ]; then
     echo "up 50%"
   else
     echo "up 100%"
   fi
   #$mysql_cmd -v -e "select @@server_uuid"
}


export -f health_check
socat tcp-listen:$1,reuseaddr,fork 'exec:bash -c health_check'

exit 0
```
#### running server as a service (using systemd)
```
[root@ibfixtest init.d]# cat /etc/systemd/system/server-agent.service
[Unit]
Description=server agent Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/sbin/server_agent 2345
Restart=always


[Install]
WantedBy=multi-user.target
```
