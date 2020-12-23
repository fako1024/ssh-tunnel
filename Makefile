VERSION_MASTER=v1.0.4
VERSION_CLIENT=v1.0.4

build-master:
	docker build master -t fako1024/ssh-tunnel-master:$(VERSION_MASTER) -f master/Dockerfile

build-client:
	docker build client -t fako1024/ssh-tunnel-client:$(VERSION_CLIENT) -f client/Dockerfile

build: build-master build-client

push-master:
	docker push fako1024/ssh-tunnel-master:$(VERSION_MASTER)

push-client:
	docker push fako1024/ssh-tunnel-client:$(VERSION_CLIENT)

push: push-master push-client
