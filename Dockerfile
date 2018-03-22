FROM alpine:edge
MAINTAINER Paul Poloskov "pavel@poloskov.net"

ENV USERNAME="samba" \
    SMBUID=1001 \
    GROUP="timemachine" \
    SMBGID=1001 \
    s6_overlay_version="1.17.1.1" 

# Install s6-overlay
ENV S6_LOGGING="0"

RUN apk --no-cache --no-progress upgrade && \
    apk add --no-cache -U samba-server samba-common-tools curl avahi && \
    OUT=$(curl https://github.com/just-containers/s6-overlay/releases/latest | cut -d '/' -f 8 | cut -d '"' -f 1) && \
    curl https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz -L -o /tmp/s6.tgz && \
    tar xvfz /tmp/s6.tgz -C / && \
    rm -f /tmp/s6.tgz && \
    apk del  --no-cache curl

COPY etc/ /etc/
COPY s6/config.init /etc/cont-init.d/00-config
COPY s6/avahi.run /etc/services.d/avahi/run
COPY s6/smbd.run /etc/services.d/smbd/run
COPY s6/nmbd.run /etc/services.d/nmbd/run

VOLUME [ "/share" "/timemachine" ]

EXPOSE 137/udp 138/udp 139/tcp 445/tcp 5353

CMD ["/init"]
