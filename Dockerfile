FROM ubuntu:14.04
MAINTAINER mail@simon-weiler.de

RUN apt-get update && apt-get install -y nginx supervisor ruby1.9.1 ruby1.9.1-dev make && rm -rf /var/lib/apt/lists/*
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN gem install bundler
RUN mkdir -p /data/www
RUN mkdir -p /data/log/nginx
RUN chown -R www-data:www-data /var/lib/nginx

RUN touch /data/log/nginx/access.log
RUN touch /data/log/nginx/error.log

RUN chown -R www-data:www-data /data/log/nginx


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf

COPY index.html /data/www/index.html

COPY admin_port /app/admin_port
WORKDIR /app/admin_port
RUN bundle install

ENV RACK_ENV production

EXPOSE 80 8080


CMD ["/usr/bin/supervisord"]
#CMD ["bundle", "exec", "rackup", "-p", "80"]
