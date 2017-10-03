FROM ubuntu:16.04

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends software-properties-common apt-transport-https apt-utils wget cabextract

RUN dpkg --add-architecture i386
RUN wget -nc https://dl.winehq.org/wine-builds/Release.key \
    && apt-key add Release.key \
    && apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
RUN apt-get update -y && apt-get install -y --install-recommends winehq-stable
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && chmod +x winetricks && mv winetricks /usr/local/bin

RUN apt-get install -y language-pack-ja-base language-pack-ja \
    tzdata \
    sudo \
    && rm -rf /var/lib/apt/lists/*

ENV TZ Asia/Tokyo
RUN echo "${TZ}" > /etc/timezone \
  && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata
ENV LANG ja_JP.UTF-8

COPY keyboard /etc/default/keyboard
RUN apt-get purge software-properties-common -y && apt-get autoclean -y
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

#RUN winetricks corefonts
#RUN winetricks fakejapanese
#RUN winetricks fontsmooth=rgb
