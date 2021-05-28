#!/bin/bash

if [ ! -e "/etc/.initialized" ];
then
	echo "Generating NetXMS server config file /etc/netxmsd.conf"
	echo -e "Logfile=/data/netxms.log\nDataDirectory=/data/netxms\nDBDriver=odbc.ddr\nDBServer=NetXMS\nDBName=${ODBC_DB_NAME}\n" >/etc/netxmsd.conf
	echo "$NETXMS_CONFIG" >> /etc/netxmsd.conf

	echo -e "[supervisord]\nnodaemon=true\n[program:netxms-server]\ncommand=/usr/bin/netxmsd -q\n[program:netxms-server-log]\ncommand=tail -f /data/netxms.log\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\n" >/etc/supervisor/conf.d/supervisord.conf

	[ "$NETXMS_STARTAGENT" -gt 0 ] && echo -e "[program:netxms-nxagent]\ncommand=/nxagent.sh\n" >>/etc/supervisor/conf.d/supervisord.conf

	touch /etc/.initialized
fi

if [ ! -d "/data/netxms" ]; then
    cp -ar /var/lib/netxms/ /data/netxms
fi

# ODBC DSN
echo "Generating ODBC config file /etc/odbc.ini"
cat > /etc/odbc.ini <<EOL
[NetXMS]
Driver = ODBC Driver 17 for SQL Server
Server = tcp:${ODBC_SQL_SERVER},1433
Database = ${ODBC_DB_NAME}
User = ${ODBC_DB_USER}
EOL

# Fix SMS kannel Drv
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libcurl.so.4
if [ "$NETXMS_UNLOCKONSTARTUP" -gt 0 ];
then
	echo "Unlocking database"
	echo "Y"|nxdbmgr unlock
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf