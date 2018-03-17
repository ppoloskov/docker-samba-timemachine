FROM fedora:rawhide
MAINTAINER Paul Poloskov "pavel@poloskov.net"

ENV USERNAME="samba" \
    SMBUID=1001 \
    GROUP="timemachine" \
    SMBGID=1001 \
    s6_overlay_version="1.17.1.1" 

# Install s6-overlay
ENV S6_LOGGING="0"

RUN set -xe;  \
    dnf -y update && \
    dnf -y install avahi curl samba && \
    dnf clean all && \
    curl -L \
        https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-amd64.tar.gz -o /tmp/s6.tgz && \
    tar zxf /tmp/s6.tgz -C / && \
    rm -rf /tmp/s6.tgz

COPY etc/ /etc/
COPY s6/config.init /etc/cont-init.d/00-config
COPY s6/avahi.run /etc/services.d/avahi/run
COPY s6/smbd.run /etc/services.d/smbd/run
COPY s6/nmbd.run /etc/services.d/nmbd/run

VOLUME [ "/share" "/timemachine" ]

EXPOSE 137/udp 138/udp 139/tcp 445/tcp 5353

CMD ["/init"]
