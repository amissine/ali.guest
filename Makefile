# Locals {{{1
SHELL := bash
RECIPES = ssh2miahub push2hub

.PHONY: $(RECIPES)

#IP=10.0.0.80
IP=73.0.2.133
ID=guest
IMAGE=ali_guest
TAG=1.0.0
ME=amissine
REPO=$(ME)/$(IMAGE)

# SSH from local docker container to miahub as $(ID) {{{1
ssh2miahub: id_ed25519
	@echo '- build and run docker container for $(IMAGE), user $(ID)@$(IP)'
	@sudo docker build \
		--build-arg ID=$(ID) --build-arg IP=$(IP) \
		-t $(IMAGE):latest .
	sudo docker run -v $$HOME:/umf -it $(IMAGE) 

id_ed25519: # {{{2
	@echo '- make keys for docker container $(IMAGE); \
		TODO MANUALLY update $(ID)@$(IP):.ssh/authorized_keys'
	@rm -f id_ed25519*; ssh-keygen -t ed25519 -f id_ed25519

# Push to hub.docker.com {{{1
push2hub:
	@echo '- build and push $(REPO):$(TAG), user $(ID)@$(IP)'
	@sudo docker build --no-cache \
		--build-arg ID=$(ID) --build-arg IP=$(IP) \
		-t $(REPO):$(TAG) .
	@sudo docker tag $(REPO):$(TAG) $(REPO):latest
	@sudo docker push $(REPO):$(TAG)
	@sudo docker push $(REPO):latest

# Notes {{{1
#
# Delete ALL docker containers and images:
#   sudo docker rm $(sudo docker ps -a | awk '{ print $1}')
#   sudo docker rmi $(sudo docker images | awk '{ print $3}')
