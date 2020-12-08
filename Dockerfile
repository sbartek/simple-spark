FROM alpine:3.12 AS simple-spark-base

ENV SPARK_VERSION=3.0.1
ENV HADOOP_VERSION=3.2
ENV SPARK_HOME=/spark

RUN apk add --no-cache curl bash openjdk8-jre python3 py-pip nss libc6-compat \
    && ln -s /lib64/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2 \
    && wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME} \
    && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && cd /

RUN echo "**** install Python 3 ****" \
    && apk add --no-cache python3 \
    && if [ -e /usr/bin/python ]; then  rm /usr/bin/python; fi \
    && ln -sf python3 /usr/bin/python \
    && echo "**** install pip ****" \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools wheel \
    && if [ -e /usr/bin/pip ]; then  rm /usr/bin/pip; fi \
    && ln -s pip3 /usr/bin/pip

ENV SPARK_MASTER "spark://simple-spark-master:7077"

# Fix the value of PYTHONHASHSEED
ENV PYTHONHASHSEED 1

FROM simple-spark-base AS simple-spark-master

COPY master.sh /

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080

EXPOSE 8080 7077 6066

CMD ["/bin/bash", "/master.sh"]


FROM simple-spark-base AS simple-spark-worker

COPY worker.sh /

ENV SPARK_WORKER_WEBUI_PORT 8081

EXPOSE 8081

CMD ["/bin/bash", "/worker.sh"]

FROM simple-spark-base AS simple-spark-job-x2

COPY submit.sh /
COPY examples/x2.py /
COPY examples/two_plus_two.py /

CMD ["/submit.sh", "/two_plus_two.py"]
