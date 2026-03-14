FROM ghcr.io/eramba/eramba:latest

USER root

RUN apt-get update && \
    apt-get install -y mysql-server redis-server cron supervisor && \
    rm -rf /var/lib/apt/lists/*

# Copier configs
COPY mysql/conf.d /etc/mysql/conf.d
COPY mysql/entrypoint /docker-entrypoint-initdb.d

COPY apache/security.conf /etc/apache2/conf-available/security.conf
COPY apache/ports.conf /etc/apache2/ports.conf
COPY apache/vhost-ssl.conf /etc/apache2/sites-available/000-default.conf

COPY apache/ssl/mycert.crt /etc/ssl/certs/mycert.crt
COPY apache/ssl/mycert.key /etc/ssl/private/mycert.key

COPY crontab/crontab /etc/cron.d/eramba-crontab

# supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod 0644 /etc/cron.d/eramba-crontab && \
    crontab /etc/cron.d/eramba-crontab

EXPOSE 443

CMD ["/usr/bin/supervisord"]
