# The default make goal is ubuntu16 
.DEFAULT_GOAL := ubuntu16

all: ubuntu16 controller

ubuntu16:
	docker build -f "docker/indy-node/Dockerfile" -t nordxdataspace/indy_node:ubuntu16 ./docker/indy-node

.PHONY: controller
controller:
	docker build -f "docker/indy-node-controller/Dockerfile" -t nordxdataspace/indy_node_controller ./docker/indy-node-controller

clean_ubuntu16:
	-docker image rm nordxdataspace/indy_node:ubuntu16

clean_controller:
	-docker image rm nordxdataspace/indy_node_controller

clean: clean_ubuntu16 clean_controller