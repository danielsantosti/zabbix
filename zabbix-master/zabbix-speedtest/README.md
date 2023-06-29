# Zabbix Speedtest
Inspired by https://github.com/pschmitt/zabbix-speedtest

With this method is the Zabbix server that get the value from the agent

Monitoring the speedtest by different ISP server


# How is work

In the speedtest.sh there is at the top some arrays with the server ids on which made the speedtest. Modify them in base of needs.

On the agent the file speedtest.sh is runned every 10 minutes and it populate with the result some files (one for each server id plus one generic for the best server) on the /tmp/ directory.
The server get this result every 600 seconds and made the graphs.

# Install instruction
- Install the speedtest-cli (pip install speedtest-cli) and jq (yum install jq)
- Copy the `speedtest.sh` to `/etc/zabbix/script` and make executable: `chmod +x /etc/zabbix/script/speedtest.sh`
- Alternative 1: Install the systemd service and timer: `cp speedtest.service speedtest.timer /etc/systemd/system` and start and enable the timer: `systemctl enable --now speedtest.timer`
- Alternative 2: Use the crontab by copy the `speedtest.cron` to `/etc/cron.d`
- Import the zabbix-agent config: `cp speedtest.conf /etc/zabbix/zabbix_agentd.conf.d/`
- Restart zabbix-agent: `systemctl restart zabbix-agent`
- Import `template_speedtest.xml` on your Zabbix server
