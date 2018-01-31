# !/bin/bash

elasticsearch/bin/elasticsearch -E http.host=0.0.0.0 --quiet & kibana/bin/kibana --host 0.0.0.0 -Q &
cd ${UPLOAD_SCRIPT_PATH}
ruby ${UPLOAD_SCRIPT_PATH}/${UPLOAD_SCRIPT_NAME}
# kill -9 $(ps -ef | grep elasticsearch | grep jdk | awk '{print $1}')
# kill -9 $(ps -ef | grep kibana | tail -1 | awk '{print $1}')
