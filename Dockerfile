FROM alpine:3.23
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.license=GPL-3.0 \
    org.label-schema.name=samba-dc \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url=https://github.com/aroth-arsoft/docker-samba

# Latest versions available on 2026-01-17:
# v3.23: 4.22.6-r0
# https://pkgs.alpinelinux.org/packages?name=samba&branch=v3.23
ARG SAMBA_VERSION=4.22.6-r0

RUN apk add --update --no-cache krb5 ldb-tools samba-dc=$SAMBA_VERSION \
      samba-winbind-clients=$SAMBA_VERSION tdb bind bind-libs bind-tools \
      libcrypto3 libxml2 tzdata acl attr py3-cryptography py3-setuptools py3-pip py3-requests && \
    pip install jinjanator --break-system-packages && \
    apk del py3-pip

ENV ADMIN_PASSWORD_SECRET=samba-admin-password \
    ALLOW_DNS_UPDATES=secure \
    BIND_INTERFACES_ONLY=yes \
    DOMAIN_ACTION=provision \
    DOMAIN_LOGONS=yes \
    DOMAIN_MASTER=no \
    INTERFACES="lo eth0" \
    LOG_LEVEL=1 \
    MODEL=standard \
    NETBIOS_NAME= \
    REALM=ad.example.com \
    SERVER_STRING="Samba Domain Controller" \
    TZ=UTC \
    WINBIND_USE_DEFAULT_DOMAIN=yes \
    WORKGROUP=AD \
    LDB_MODULES_PATH="/usr/lib/samba/ldb" \
    WEBURL= \
    MAILSERVER=

VOLUME /etc/samba /var/lib/samba
EXPOSE 53 53/udp 88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-65535

COPY *.conf.j2 /root/
COPY entrypoint.sh samba-password-expire /usr/local/bin/
RUN chmod 0755 /usr/local/bin/entrypoint.sh /usr/local/bin/samba-password-expire

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
