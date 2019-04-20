FROM ubuntu:18.04
MAINTAINER contact@thachmai.info

RUN echo "### 1) configure tzdata to avoid interactive prompts ###" && \
    ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime && dpkg --configure -a && \
    echo "### 2) install certbot (https://certbot.eff.org/lets-encrypt/ubuntubionic-other) ###" && \
    apt-get update && apt-get install software-properties-common -y && \
    add-apt-repository universe -y && add-apt-repository ppa:certbot/certbot -y && \
    apt-get update && apt-get install certbot -y && \
    echo "### 3) install acme-dns-certbot plugin for certbot (https://github.com/joohoi/acme-dns-certbot-joohoi) ###" && \
    apt-get install curl -y && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    curl -o /usr/local/bin/acme-dns-auth.py https://raw.githubusercontent.com/joohoi/acme-dns-certbot-joohoi/master/acme-dns-auth.py && \
    chmod 0700 /usr/local/bin/acme-dns-auth.py 

# "--debug-challenges" is need for the auth-hook to pause: https://github.com/joohoi/acme-dns-certbot-joohoi#usage
ENTRYPOINT ["/usr/bin/certbot", \
           "--manual", "--manual-auth-hook", "/usr/local/bin/acme-dns-auth.py", /
           "--debug-challenges", /
           "--preferred-challenges", "dns", /
           "--agree-tos", "--manual-public-ip-logging-ok", /
           "--server", "https://acme-v02.api.letsencrypt.org/directory"]