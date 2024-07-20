VERSION=v1.0.8

build-master:
	docker build master -t fako1024/ssh-tunnel-master:$(VERSION) -f master/Dockerfile

build-client:
	docker build client -t fako1024/ssh-tunnel-client:$(VERSION) -f client/Dockerfile

build: build-master build-client

push-master:
	docker push fako1024/ssh-tunnel-master:$(VERSION)

push-client:
	docker push fako1024/ssh-tunnel-client:$(VERSION)

push: push-master push-client

release:
	git tag $(VERSION)
	git push origin $(VERSION)
