FROM ghcr.io/eramba/eramba:latest

USER root

RUN apt-get update && apt-get install -y wget gnupg lsb-release

RUN wget https://repo.mysql.com/mysql-apt-config_0.8.29-1_all.deb

RUN dpkg -i mysql-apt-config_0.8.29-1_all.deb

RUN apt-get update && \
    apt-get install -y mysql-server

    

# Copier configs
COPY mysql/conf.d /etc/mysql/conf.d
COPY mysql/entrypoint /docker-entrypoint-initdb.d

COPY apache/security.conf /etc/apache2/conf-available/security.conf
COPY apache/ports.conf /etc/apache2/ports.conf
COPY apache/vhost.conf /etc/apache2/sites-available/000-default.conf

COPY apache/ssl/mycert.crt /etc/ssl/certs/mycert.crt
COPY apache/ssl/mycert.key /etc/ssl/private/mycert.key

COPY crontab/crontab /etc/cron.d/eramba-crontab

# supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod 0644 /etc/cron.d/eramba-crontab && \
    crontab /etc/cron.d/eramba-crontab

EXPOSE 80

CMD ["/usr/bin/supervisord"]
