# Dockerfile for building NetXMS server image

FROM debian:stretch 
MAINTAINER Marcus Halmsjö <duragizer@gmail.com>

ARG NETXMS_VERSION_SERVER=3.8.366-1

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
		apt-utils \
        gnupg2 \
        apt-transport-https \
        ca-certificates \
        curl \
        netcat \
		odbcinst1debian2 \
		libodbc1 \
		odbcinst \
		unixodbc \
    && \
    apt-get install -y --no-install-recommends locales && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend noninteractive locales && \
    \
    apt-get -qq clean

RUN curl -sL http://packages.netxms.org/netxms.gpg | apt-key add - && \
	curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    echo "deb http://packages.netxms.org/debian/ stretch  main" > /etc/apt/sources.list.d/netxms.list && \
	curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    apt-get -y install libssl1.1 libzmq5 && \
    apt-get -y install netxms-server=$NETXMS_VERSION_SERVER netxms-dbdrv-odbc=$NETXMS_VERSION_SERVER && \
	echo msodbcsql17 msodbcsql/ACCEPT_EULA boolean true | debconf-set-selections && \
	apt-get -y install msodbcsql17 libgssapi-krb5-2 && \
    apt-get clean && \
    mkdir -p /usr/share/netxms/default-templates && \
    mv /usr/share/netxms/templates/* /usr/share/netxms/default-templates/

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US \
    LC_ALL=en_US.UTF-8 \
    NETXMSD_UNLOCK_ON_STARTUP=1 \
    NETXMSD_UPGRADE_ON_STARTUP=1 \
    NETXMSD_DEBUG_LEVEL=0

VOLUME /data

EXPOSE 4701
EXPOSE 514/udp

COPY ./docker-entrypoint.sh ./wait-for /

RUN  chmod 755 /docker-entrypoint.sh && chmod 755 /wait-for

CMD ["/docker-entrypoint.sh"]
