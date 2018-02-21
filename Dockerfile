FROM fedora:rawhide
MAINTAINER Paul Poloskov "pavel@poloskov.net"

ENV USERNAME="paul"
ENV GROUP="timemachine"

RUN yum -y update; yum -y install avahi supervisor samba; yum clean all; yum -y autoremove; rm -rf /var/cache/dnf/*

COPY config/ /etc/
COPY bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/addUser /usr/local/bin/delUser
RUN set -xe \
    && groupadd -r ${GROUP} \
    && useradd -D --no-log-init -r -g ${GROUP} ${USERNAME} \
    && PASSWORD=$(cat /dev/urandom | tr -dc "a-zA-Z0-9-_" | fold -w 50 | head -n1) \
    && (echo "$PASSWORD"; echo "$PASSWORD") | smbpasswd -sa -c /config/smb.conf $USERNAME
    
   # && chmod -R +x /usr/local/bin/run.sh /etc/s6.d \
   # && chown -R $USERNAME:$USERNAME /etc/s6.d /var/log/samba /var/cache/samba /var/lib/samba /var/run/samba

VOLUME [ "/timemachine" ]
EXPOSE 5353 445

ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
