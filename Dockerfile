FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends software-properties-common apt-transport-https apt-utils wget cabextract gpg-agent git sudo xz-utils

ENV TZ Asia/Tokyo

RUN apt-get install -y \
    language-pack-ja-base language-pack-ja \
    tzdata

RUN echo "${TZ}" > /etc/timezone \
        && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
        && dpkg-reconfigure -f noninteractive tzdata

ENV LANG ja_JP.UTF-8

RUN dpkg --add-architecture i386 \
        && apt-get update -y && apt-get install -y wine32 winetricks

COPY keyboard /etc/default/keyboard
RUN apt-get purge software-properties-common -y \
        && apt-get autoclean -y && rm -rf /var/lib/apt/lists/*

RUN export uid=1000 gid=1000 && \
    mkdir -p /home/wineuser && \
    echo "wineuser:x:${uid}:${gid}:Developer,,,:/home/wineuser:/bin/bash" >> /etc/passwd && \
    echo "wineuser:x:${uid}:" >> /etc/group && \
    echo "wineuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wineuser && \
    chmod 0440 /etc/sudoers.d/wineuser && \
    chown ${uid}:${gid} -R /home/wineuser

USER wineuser
ENV HOME /home/wineuser
WORKDIR /home/wineuser

#RUN winetricks fakejapanese
#RUN winetricks fontsmooth=rgb
#RUN winetricks cjkfonts
