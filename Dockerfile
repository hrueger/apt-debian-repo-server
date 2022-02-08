FROM ubuntu:focal
LABEL org.opencontainers.image.authors="Hannes Rüger"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends dpkg-dev nginx inotify-tools supervisor && apt-get autoclean && apt-get autoremove
RUN rm -rf /var/lib/apt/lists/*

ADD ./configs/supervisord.conf /etc/supervisor/
ADD ./configs/nginx.conf /etc/nginx/sites-enabled/default

ADD ./repo-scripts/ /repo-scripts
ADD ./package-generator/ /package-generator

ENV DISTS focal
ENV ARCHS amd64,i386
EXPOSE 80

ENTRYPOINT ["/repo-scripts/startup.sh"]
