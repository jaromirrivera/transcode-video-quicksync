FROM denismakogon/ffmpeg-alpine:4.0-buildstage as build-stage

FROM jlesage/handbrake

COPY --from=build-stage /tmp/fakeroot/bin /usr/local/bin
COPY --from=build-stage /tmp/fakeroot/share /usr/local/share
COPY --from=build-stage /tmp/fakeroot/include /usr/local/include
COPY --from=build-stage /tmp/fakeroot/lib /usr/local/lib

RUN apk add --no-cache --update --virtual=build-dependencies \
    make \
    gcc \
    g++ \
    ruby \
    ruby-bundler \
    ruby-rdoc \
    mkvtoolnix \
    #mpv \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    && apk add --update fdk-aac fdk-aac-dev && \
echo "---- COMPILE SANDREAS MP4V2 ----" \
    && cd /tmp/ \
    && wget https://github.com/sandreas/mp4v2/archive/master.zip \
    && unzip master.zip \
    && rm master.zip \
    && cd mp4v2-master \
    && ./configure && make -j4 && make install && make distclean && rm -rf /tmp/* \
    && mkdir /data 
# echo "---- COMPILE FDKAAC ----" \
#     && cd /tmp/ \
#     && wget https://github.com/nu774/fdkaac/archive/1.0.0.tar.gz \
#     && tar xzf 1.0.0.tar.gz \
#     && rm 1.0.0.tar.gz \
#     && cd fdkaac-1.0.0 \
#     && autoreconf -i && ./configure && make -j4 && make install && rm -rf /tmp/* && \
RUN gem install video_transcoding

WORKDIR /data