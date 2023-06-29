# Zabbix Speedtest LAN
With this method is the Zabbix server that get the value from the agent

Monitoring the speedtest on the LAN (using iperf3)

 
# How is work

In the speedtest-lan.sh there is at the top the arrays with data of each server on which made the speedtest. Modify them in base of needs (trigger, ip/hostname...).

On the agent the file speedtest-lan.sh is runned every 10 minutes and it populate with the result some files (one for each server id) on the /tmp/ directory.
The server get this result every 600 seconds and made the graphs.

# Install instruction
- Install the iperf3 on the server and set start as server on the boot
- Install the iperf3 on the agent
- Copy the `speedtest-lan.sh` to `/etc/zabbix/script` and make executable: `chmod +x /etc/zabbix/script/speedtest-lan.sh`
- Alternative 1: Install the systemd service and timer: `cp speedtest-lan.service speedtest-lan.timer /etc/systemd/system` and start and enable the timer: `systemctl enable --now speedtest-lan.timer`
- Alternative 2: Use the crontab by copy the `speedtest-lan.cron` to `/etc/cron.d`
- Import the zabbix-agent config: `cp speedtest-lan.conf /etc/zabbix/zabbix_agentd.conf.d/`
- Restart zabbix-agent: `systemctl restart zabbix-agent`
- Import `template_speedtest-lan.xml` on your Zabbix server
