#!/bin/bash

# https://wiki.netxms.org/wiki/Server_Configuration_File

odbc_ini=/etc/odbc.ini
netxmsd_conf=/data/netxmsd.conf
#netxmsd_db_path=/data/netxms.db
netxmsd_log_file=/data/netxms.log
netxmsd_data_directory=/data/netxms
#netxmsd_predefined_templates=/data/predefined-templates

if [ ! -f "${netxmsd_conf}" ];
then
    echo "Generating NetXMS server config file ${netxmsd_conf}"
    cat > ${netxmsd_conf} <<EOL
DBDriver=odbc.ddr
DBServer=NetXMS
DBName=${ODBC_DB_NAME}
Logfile=${netxmsd_log_file}
DataDirectory=${netxmsd_data_directory}
${NETXMSD_CONFIG}
EOL

fi

#if [ ! -f "${odbc_ini}" ];
#then
    echo "Generating ODBC config file ${odbc_ini}"
    cat > ${odbc_ini} <<EOL
[NetXMS]
Driver = ODBC Driver 17 for SQL Server
Server = tcp:${ODBC_SQL_SERVER},1433
Database = ${ODBC_DB_NAME}
User = ${ODBC_DB_USER}
Password = ${ODBC_DB_PASS}
Trusted_Connection=yes
EOL

#fi

if [ ! -d "${netxmsd_data_directory}" ]; then
    cp -ar /var/lib/netxms/ ${netxmsd_data_directory}
fi

#if [ ! -d "${netxmsd_predefined_templates}" ]; then
#    cp -ar /usr/share/netxms/default-templates/ ${netxmsd_predefined_templates}
#fi

#if [ ! -f "${netxmsd_db_path}" ]; then
#    echo "Initializing NetXMS SQLLite database"
#    nxdbmgr -c ${netxmsd_conf} init /usr/share/netxms/sql/dbinit_sqlite.sql
#fi

if [ "${NETXMSD_UNLOCK_ON_STARTUP}" -gt 0 ]; then
    echo "Unlocking database"
    echo "Y" | nxdbmgr -c ${netxmsd_conf} unlock
fi

if [ "${NETXMSD_UPGRADE_ON_STARTUP}" -gt 0 ]; then
    echo "Upgrading database"
    nxdbmgr ${NETXMSD_UPGRADE_PARAMS} -c ${netxmsd_conf} upgrade
fi

# Usage: netxmsd [<options>]
# 
# Valid options are:
#    -e          : Run database check on startup
#    -c <file>   : Set non-default configuration file
#    -d          : Run as daemon/service
#    -D <level>  : Set debug level (valid levels are 0..9)
#    -h          : Display help and exit
#    -p <file>   : Specify pid file.
#    -q          : Disable interactive console
#    -v          : Display version and exit

netxmsd_debug_level=""
if [ "$NETXMSD_DEBUG_LEVEL" -gt 0 ]; then
    netxmsd_debug_level="-D ${NETXMSD_DEBUG_LEVEL}"
fi

exec /usr/bin/netxmsd -q ${netxmsd_debug_level} -c ${netxmsd_conf}
