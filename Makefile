# Makefile for building and running the Docker image

# Variables
IMAGE_NAME := gencore/llama-cpp-qwen3
tag ?= ${0_6_MODEL_VERSION}
DOCKERFILE := docker/Dockerfile

0_6_MODEL_NAME=Qwen/Qwen3-0.6B-GGUF
0_6_MODEL_FILE=Qwen3-0.6B-Q8_0.gguf
0_6_MODEL_VERSION=0.6B

1_7_MODEL_NAME=Qwen/Qwen3-1.7B-GGUF
1_7_MODEL_FILE=Qwen3-1.7B-Q8_0.gguf
1_7_MODEL_VERSION=1.7B

# Targets
.PHONY: build run

build: build_0_6 build_1_7

build_0_6:
	DOCKER_BUILDKIT=1 docker build \
	-f $(DOCKERFILE) . \
	--build-arg MODEL_NAME="${0_6_MODEL_NAME}" \
	--build-arg MODEL_FILE="${0_6_MODEL_FILE}" \
	-t $(IMAGE_NAME):${0_6_MODEL_VERSION}

build_1_7:
	DOCKER_BUILDKIT=1 docker build \
	-f $(DOCKERFILE) . \
	--build-arg MODEL_NAME="${1_7_MODEL_NAME}" \
	--build-arg MODEL_FILE="${1_7_MODEL_FILE}" \
	-t $(IMAGE_NAME):${1_7_MODEL_VERSION}

run:
	docker run --rm -i $(IMAGE_NAME):$(tag)

publish:
	@echo "Pushing to DockerHub"
	@sh utils/docker-login
	docker push $(IMAGE_NAME):${1_7_MODEL_VERSION}
	docker push $(IMAGE_NAME):${0_6_MODEL_VERSION}