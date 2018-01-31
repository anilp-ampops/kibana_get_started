FROM openjdk:jre-alpine

LABEL maintainer "AMP-OPS anilp.amp.ops@gmail.com"

ENV ES_VERSION=5.6.2 \
    KIBANA_VERSION=5.6.2 \
    UPLOAD_SCRIPT_PATH="/home/elasticsearch/uploadscript" \
    UPLOAD_SCRIPT_NAME="createDashboard.rb"

RUN apk add --quiet --no-progress --no-cache nodejs wget \
 && adduser -D elasticsearch

RUN apk --update add bash ruby ruby-dev g++ make
RUN apk --update add ruby-irb ruby-rdoc
RUN gem install rest-client yajl

COPY script/* ${UPLOAD_SCRIPT_PATH}/
COPY json/* ${UPLOAD_SCRIPT_PATH}/
RUN chown elasticsearch:elasticsearch -R ${UPLOAD_SCRIPT_PATH} && chmod 755 ${UPLOAD_SCRIPT_PATH}/runScript.sh

USER elasticsearch

WORKDIR /home/elasticsearch

RUN wget -q -O - https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz \
 |  tar -zx \
 && mv elasticsearch-${ES_VERSION} elasticsearch \
 && wget -q -O - https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz \
 |  tar -zx \
 && mv kibana-${KIBANA_VERSION}-linux-x86_64 kibana \
 && rm -f kibana/node/bin/node kibana/node/bin/npm \
 && ln -s $(which node) kibana/node/bin/node \
 && ln -s $(which npm) kibana/node/bin/npm

RUN ${UPLOAD_SCRIPT_PATH}/runScript.sh

CMD sh elasticsearch/bin/elasticsearch -E http.host=0.0.0.0 --quiet & kibana/bin/kibana --host 0.0.0.0 -Q

EXPOSE 9200 5601
