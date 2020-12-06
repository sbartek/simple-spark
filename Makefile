build:
	docker build --target simple-spark-master -t barteks/simple-spark-master .
	docker build --target simple-spark-worker -t barteks/simple-spark-worker .
	docker build --target simple-spark-job-x2 -t barteks/simple-spark-job-x2 .

run:
	docker network create simple-spark-cluster || true
	docker run --network simple-spark-cluster -d --rm -p 8080:8080 -p 7077:7077\
		--name simple-spark-master\
		barteks/simple-spark-master
	docker run --network simple-spark-cluster -d --rm -p 8081:8081 \
		--name simple-spark-worker-1 \
		-e SPARK_MASTER='spark://simple-spark-master:7077' \
		barteks/simple-spark-worker

submit_x2:
	docker run --network simple-spark-cluster barteks/simple-spark-job-x2

submit_local_x2:
	export SPARK_MASTER='spark://localhost:7077' && ./submit.sh examples/x2.py 


push:
	docker push barteks/simple-spark-master
	docker push barteks/simple-spark-worker
	docker push barteks/simple-spark-job-x2
