#!/bin/bash

export SPARK_MASTER_URL=spark://${SPARK_MASTER_NAME}:${SPARK_MASTER_PORT}
export SPARK_HOME=/spark

echo "Submit application to Spark master ${SPARK_MASTER_URL}"

${SPARK_HOME}/bin/spark-submit --master ${SPARK_MASTER_URL} $1
