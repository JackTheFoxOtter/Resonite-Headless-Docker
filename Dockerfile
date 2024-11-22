FROM mcr.microsoft.com/dotnet/runtime:9.0

LABEL name=resonite-headless maintainer="jackthefoxotter@gmail.com"

ARG	HOSTUSERID
ARG	HOSTGROUPID

ENV	STEAMAPPID=2519830 \
	STEAMAPP=resonite \
	STEAMCMDURL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
	STEAMCMDDIR=/opt/steamcmd \
	STEAMBETA=headless \
	STEAMLOGIN=__CHANGEME__ \
	USER=resonite \
	HOMEDIR=/home/resonite
ENV	STEAMAPPDIR="${HOMEDIR}/${STEAMAPP}-headless"

# Prepare the basic environment
RUN	set -x && \
	apt-get -y update && \
	apt-get -y upgrade && \
	apt-get -y install curl libfreetype6 lib32gcc-s1 libopus-dev libopus0 opus-tools && \
	rm -rf /var/lib/{apt,dpkg,cache}

# Add locales
RUN	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y locales

RUN	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=en_US.UTF-8 && \
	update-locale LANG=en_GB.UTF-8 && \
	rm -rf /var/lib/{apt,dpkg,cache}

ENV	LANG en_GB.UTF-8

# Fix the LetsEncrypt CA cert
RUN	sed -i 's#mozilla/DST_Root_CA_X3.crt#!mozilla/DST_Root_CA_X3.crt#' /etc/ca-certificates.conf && update-ca-certificates

# Create user, install SteamCMD
RUN	addgroup --gid ${HOSTGROUPID} ${USER}

RUN	adduser \
	--disabled-login \
	--shell /bin/bash \
	--gecos "" \
	--gid ${HOSTGROUPID} \
	--uid ${HOSTUSERID} \
	${USER}

RUN	mkdir -p ${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR} /Config /Logs /Scripts /Headless/Data /Headless/Data/Cache /Headless/Data/Assets /Headless/RuntimeData && \
	cd ${STEAMCMDDIR} && \
	curl -sqL ${STEAMCMDURL} | tar zxfv - && \
	chown -R ${USER}:${USER} ${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR} /Config /Logs /Scripts

COPY ./setup_resonite.sh ./start_resonite.sh /Scripts/

RUN	chown -R ${USER}:${USER} /Scripts/setup_resonite.sh /Scripts/start_resonite.sh && \
	chmod +x /Scripts/setup_resonite.sh /Scripts/start_resonite.sh

# Switch to user
USER ${USER}

WORKDIR ${STEAMAPPDIR}

VOLUME ["${STEAMAPPDIR}", "/Config", "/Logs"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/Scripts/setup_resonite.sh"]
CMD ["/Scripts/start_resonite.sh"]
