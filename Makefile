PROJECT_NAME := $(notdir $(CURDIR))
IMAGE_NAME := ${PROJECT_NAME}-app

extract-lock:
	@echo "Extracting poetry.lock from container..."
	@docker create --name temp-extract ${IMAGE_NAME}
	@docker cp temp-extract:/code/poetry.lock ./app/poetry.lock
	@docker rm temp-extract
	@echo "Lock file updated locally."

build:
	docker compose -f docker-compose.yaml build

build-update:
	@echo "Deleting lock file..."
	rm -f app/poetry.lock
	@echo "Rebuilding image..."
	docker compose -f docker-compose.yaml build
	@$(MAKE) extract-lock

build-gpu:
	docker compose -f docker-compose.yaml -f docker-compose-nvidia.yaml build

up:
	docker compose -f docker-compose.yaml up

up-gpu:
	docker compose -f docker-compose.yaml -f docker-compose-nvidia.yaml up

command:
	docker exec -it ${IMAGE_NAME} /bin/bash

command-raw:
	docker compose run ${IMAGE_NAME} bash

command-raw-gpu:
	docker compose -f docker-compose.yaml -f docker-compose-nvidia.yaml run ${IMAGE_NAME} bash

clean-requirements:
	rm -f app/poetry.lock
	