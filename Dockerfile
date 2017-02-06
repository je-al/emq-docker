FROM alpine:3.4

MAINTAINER Huang Rui <vowstar@gmail.com>

ENV EMQ_VERSION=v2.0.7

ADD ./start.sh /start.sh

RUN apk --no-cache add \
        ncurses-terminfo-base \
        ncurses-terminfo \
        ncurses-libs \
        readline \
    && apk --no-cache add --virtual=build-dependencies \
        erlang \
        erlang-public-key \
        erlang-syntax-tools \
        erlang-erl-docgen \
        erlang-gs \
        erlang-observer \
        erlang-ssh \
        erlang-ose \
        erlang-cosfiletransfer \
        erlang-runtime-tools \
        erlang-os-mon \
        erlang-tools \
        erlang-cosproperty \
        erlang-common-test \
        erlang-dialyzer \
        erlang-edoc \
        erlang-otp-mibs \
        erlang-crypto \
        erlang-costransaction \
        erlang-odbc \
        erlang-inets \
        erlang-asn1 \
        erlang-snmp \
        erlang-erts \
        erlang-et \
        erlang-cosnotification \
        erlang-xmerl \
        erlang-typer \
        erlang-coseventdomain \
        erlang-stdlib \
        erlang-diameter \
        erlang-hipe \
        erlang-ic \
        erlang-eunit \
        erlang-webtool \
        erlang-mnesia \
        erlang-erl-interface \
        erlang-test-server \
        erlang-sasl \
        erlang-jinterface \
        erlang-kernel \
        erlang-orber \
        erlang-costime \
        erlang-percept \
        erlang-dev \
        erlang-eldap \
        erlang-reltool \
        erlang-debugger \
        erlang-ssl \
        erlang-megaco \
        erlang-parsetools \
        erlang-cosevent \
        erlang-compiler \
        git \
        make \
        perl \
    && git clone -b ${EMQ_VERSION} https://github.com/emqtt/emq-relx.git /emqttd \
    && cd /emqttd \
    && make \
    && mkdir /opt && mv /emqttd/_rel/emqttd /opt/emqttd \
    && cd / && rm -rf /emqttd \
    && mv /start.sh /opt/emqttd/start.sh \
    && chmod +x /opt/emqttd/start.sh \
    && apk --purge del build-dependencies \
    && rm -rf /var/cache/apk/*

# gucci
ENV GC_VERSION=v0.0.4
ENV GC_SHA1=cfdf435666c8d9541c30e39a02da2ac019ceaeb6
RUN apk --no-cache add --virtual=fetch-dependencies \
    openssl \
  && wget -qO /usr/local/bin/gucci "https://github.com/noqcks/gucci/releases/download/${GC_VERSION}/gucci-${GC_VERSION}-linux-amd64" \
  && echo "${GC_SHA1}  /usr/local/bin/gucci" | sha1sum -c \
  && chmod +x /usr/local/bin/gucci \
  && apk --purge del fetch-dependencies

# configuration processing
COPY preprocess/ /opt/preprocess
RUN apk --no-cache add --virtual=prep-dependencies \
      python \
    && /opt/preprocess/init.sh \
    && apk --purge del prep-dependencies

# startup
ENV PATH=$PATH:/opt/emqttd/bin
RUN apk --no-cache add supervisor
COPY emqtt.ini /etc/supervisor.d/emqtt.ini
COPY ./myemqenv /myemqenv

HEALTHCHECK --interval=30s --timeout=3s \
  CMD . /myemqenv; emqttd_ctl status

WORKDIR /opt/emqttd

# start emqttd and initial environments
CMD ["/usr/bin/supervisord"]

VOLUME ["/opt/emqttd/log", "/opt/emqttd/data", "/opt/emqttd/plugins", "/opt/emqttd/etc"]

# emqttd will occupy these port:
# - 1883 port for MQTT
# - 8883 port for MQTT(SSL)
# - 8083 for WebSocket/HTTP
# - 8084 for WSS/HTTPS
# - 18083 for dashboard
# - 4369 for port mapping
# - 6000-6999 for distributed node
EXPOSE 1883 8883 8083 8084 18083 4369 6000-6999
