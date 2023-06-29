# Zabbix Speedtest LAN Sender

With this method is the Zabbix agent that send the value to the server

Monitoring the speedtest on the LAN (using iperf3) by send value to Zabbix server

# How is work

In the zabbix_speedtest-lan.sh there is the command for make the iperf3 test.

On the agent the file zabbix_speedtest-lan.sh is runned every 10 minutes and it send the data (upload and download speed) to Zabbix server.


# Install instruction

- Install the iperf3 on the server and set start as server on the boot
- Install the iperf3 on the agent
- Copy the `zabbix_speedtest-lan.sh` to `/etc/zabbix/script` and make executable: `chmod +x /etc/zabbix/script/zabbix_speedtest-lan.sh`
- Set the address of iperf3 server in the `zabbix_speedtest-lan.sh` 
- Set the crontab by copy the `speedtest-lan.cron` to `/etc/cron.d`
- Import `template_speedtest-lan_sender.xml` on your Zabbix server