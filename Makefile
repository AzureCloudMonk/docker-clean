.PHONY: release

SHELL := /bin/bash
PKG_NAME=$(shell basename `pwd`)
GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
DOCKER_CLEAN_VERSION=v2.0.4
IMAGE_BASE_NAME=zzrot/docker-clean
DOCKER_VERSION_TAG_1_11_1=$(IMAGE_BASE_NAME):docker-1.11.1
DOCKER_VERSION_TAG_LATEST=$(IMAGE_BASE_NAME)
DOCKER_TAG_LITE=$(IMAGE_BASE_NAME):$(DOCKER_CLEAN_VERSION)-lite
DOCKER_FILE_DIR_PATH=./dockerfiles

release:
	docker build -t $(DOCKER_VERSION_TAG_LATEST) $(DOCKER_FILE_DIR_PATH)/
	docker build -t $(DOCKER_VERSION_TAG_1_11_1) -f $(DOCKER_FILE_DIR_PATH)/Dockerfile-1.11.1 .
	docker build -t $(DOCKER_TAG_LITE) -f $(DOCKER_FILE_DIR_PATH)/Dockerfile-lite .
	docker push $(DOCKER_VERSION_TAG_LATEST)
	docker push $(DOCKER_VERSION_TAG_1_11_1)
	docker push $(DOCKER_TAG_LITE)
