FROM alpine:edge
#FROM alpine:3.13
MAINTAINER Rich Braun "docker@instantlinux.net"
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.license=GPL-3.0 \
    org.label-schema.name=samba-dc \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url=https://github.com/aroth-arsoft/docker-samba

# Latest versions available on 2021-04-01:
# edge: 4.14.2-r0
# v3.13: 4.13.7-r0
ARG SAMBA_VERSION=4.14.2-r0

RUN apk add --update --no-cache krb5 ldb-tools samba-dc=$SAMBA_VERSION tdb \
      bind bind-libs bind-tools libcrypto1.1 libxml2 tzdata

ENV ADMIN_PASSWORD_SECRET=samba-admin-password \
    ALLOW_DNS_UPDATES=secure \
    BIND_INTERFACES_ONLY=yes \
    DOMAIN_ACTION=provision \
    DOMAIN_MASTER=no \
    INTERFACES="lo eth0" \
    LOG_LEVEL=1 \
    MODEL=standard \
    NETBIOS_NAME= \
    REALM=ad.example.com \
    SERVER_STRING="Samba Domain Controller" \
    TZ=UTC \
    WINBIND_USE_DEFAULT_DOMAIN=yes \
    WORKGROUP=AD

VOLUME /etc/samba /var/lib/samba
EXPOSE 53 53/udp 88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-65535

COPY *.conf.j2 /root/
COPY entrypoint.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
