#FROM ubuntu:trusty
#FROM ubuntu:xenial
#FROM ubuntu:bionic
FROM ubuntu:focal 

ENV TZ=Asia/Taipei

COPY init.sh /tmp

RUN set -x \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
	&& echo $TZ > /etc/timezone \
    && echo "security.jail.allow_raw_sockets=1" >> /etc/sysctl.conf \
    && sh /tmp/init.sh \
    && rm -rf /tmp/* \
    && apt-get autoremove -y gcc autoconf make wget unzip bc gawk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*