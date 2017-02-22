FROM ubuntu:16.04
MAINTAINER Giovanni Curiel <gcuriel@cpqd.com.br>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
        python-pip python-dev uwsgi-plugin-python \
        nginx supervisor \
    && pip install uwsgi pymongo flask flask-cors requests


COPY docker/nginx/flask.conf /etc/nginx/sites-available/
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/app/uwsgi.ini /var/www/app/uwsgi.ini

RUN mkdir -p /var/log/nginx/app /var/log/uwsgi/app /var/log/supervisor /var/www/app/icons \
    && rm /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/flask.conf /etc/nginx/sites-enabled/flask.conf \
    && echo "daemon off;" >> /etc/nginx/nginx.conf \
    && chown -R www-data:www-data /var/www/app \
    && chown -R www-data:www-data /var/log

COPY *.py /var/www/app/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

EXPOSE 5000