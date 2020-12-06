build:
	docker build --target simple-spark-master -t barteks/simple-spark-master .
	docker build --target simple-spark-worker -t barteks/simple-spark-worker .

run:
	docker network create simple-spark-cluster || true
	docker run --network simple-spark-cluster -d --rm -p 8080:8080 \
		--name simple-spark-master\
		barteks/simple-spark-master
	docker run --network simple-spark-cluster -d --rm -p 8081:8081 \
		--name simple-spark-worker-1 \
		-e SPARK_MASTER='spark://simple-spark-master:7077' \
		barteks/simple-spark-worker
