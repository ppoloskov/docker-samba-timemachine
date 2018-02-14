FROM fedora:rawhide
MAINTAINER Paul Poloskov "pavel@poloskov.net"

ENV USER="paul"
ENV GROUP="timemachine"

RUN yum -y update; yum -y install avahi supervisor samba; yum clean all; yum -y autoremove; rm -rf /var/cache/dnf/*

COPY config/ /etc/
COPY bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/addUser /usr/local/bin/delUser
RUN groupadd -r ${GROUP} && \
    useradd --no-log-init -r -g ${GROUP} ${USER}



VOLUME [ "/timemachine" ]
EXPOSE 5353 445

ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
