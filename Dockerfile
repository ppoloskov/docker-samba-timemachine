FROM fedora:rawhide
MAINTAINER Paul Poloskov "pavel@poloskov.net"

ENV USERNAME="paul"
ENV GROUP="timemachine"
ENV s6_overlay_version="1.17.1.1"

# Install s6-overlay
ENV S6_LOGGING="1"

RUN yum -y update; yum -y install avahi curl samba; yum clean all; yum -y autoremove; rm -rf /var/cache/dnf/*

COPY config/ /etc/
COPY bin/ /usr/local/bin/

RUN chmod +x /usr/local/bin/addUser /usr/local/bin/delUser
RUN set -xe \
    && curl -L \
        https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz \
        -o /tmp/s6-overlay-amd64.tar.gz \
    && tar zxf /tmp/s6-overlay-amd64.tar.gz -C / \
    && rm -rf /tmp/s6-overlay-amd64.tar.gz \
    && groupadd -r ${GROUP} \
    && useradd -D --no-log-init -r -g ${GROUP} ${USERNAME} \
    && PASSWORD=$(cat /dev/urandom | tr -dc "a-zA-Z0-9-_" | fold -w 50 | head -n1) \
    && (echo "$PASSWORD"; echo "$PASSWORD") | smbpasswd -sa -c /config/smb.conf $USERNAME
    
   # && chmod -R +x /usr/local/bin/run.sh /etc/s6.d \
   # && chown -R $USERNAME:$USERNAME /etc/s6.d /var/log/samba /var/cache/samba /var/lib/samba /var/run/samba

VOLUME [ "/timemachine" ]

EXPOSE 137/udp 138/udp 139/tcp 445/tcp 5353

CMD ["/init"]
