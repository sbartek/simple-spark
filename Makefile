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

submit_local_x2:
	export SPARK_MASTER='spark://localhost:7077' && ./submit.sh examples/x2.py 

compile_scala_x2:
	cd examples/simple-spark-job && sbt package

submit_local_scala_x2:
	export SPARK_MASTER='spark://localhost:7077' && ./submit.sh examples/simple-spark-job/target/scala-2.12/hello-spark_2.12-0.1.jar

submit_x2:
	docker run --network simple-spark-cluster simple-spark-job-x2



push:
	docker push barteks/simple-spark-master
	docker push barteks/simple-spark-worker
	docker push barteks/simple-spark-job-x2

declarative_create_spark_cluster:
	kubectl create deployment simple-spark-master --image barteks/simple-spark-master
	kubectl expose deployment simple-spark-master --type=LoadBalancer --port 8080

create_spark_cluster:
	kubectl apply -f k8s/simple-spark-master-pod.yaml

port-forward-spark:
	kubectl port-forward simple-spark-master 8080	

minikube:
	minikube config set memory 8192
	minikube config set cpus 4
	minikube start

docker_k8s_build-14:
	cd ${SPARK_HOME} &&\
	./bin/docker-image-tool.sh -r barteks -t v3.0.1-j14 -p kubernetes/dockerfiles/spark/bindings/python/Dockerfile -b java_image_tag=14-slim build

docker_k8s_build-8:
	cd ${SPARK_HOME} &&\
	./bin/docker-image-tool.sh -r barteks -t v3.0.1-8-jre-slim -p kubernetes/dockerfiles/spark/bindings/python/Dockerfile -b java_image_tag=8-jre-slim build
