FROM ubuntu:focal
MAINTAINER Cem Topkaya

ENV DEBIAN_FRONTEND noninteractive

# supervisor için http://supervisord.org/running.html
RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
    &&   dpkg-dev \
    &&   nginx \
    &&   inotify-tools \ 
    &&   supervisor \
    &&   python-gevent \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ADD supervisord.conf /etc/supervisor/
ADD nginx.conf /etc/nginx/sites-enabled/default
ADD startup.sh /
ADD scan.py /

ENV DISTS trusty
ENV ARCHS amd64,i386
EXPOSE 80
VOLUME /data
ENTRYPOINT ["/startup.sh"]
