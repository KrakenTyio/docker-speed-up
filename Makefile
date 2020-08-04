NG_EXTRA:=
DOCKER_EXTRA:=
THPRO:=
DCUID:=$(shell id -u)
DCGID:=$(shell id -g)
CI_TARGET_HOST:=$(shell ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+' || printf '172.17.0.1')

setup:
	git submodule update --init --remote

deinit:
	git submodule deinit --all -f

reimage:
	DCUID=${DCUID} \
	DCGID=${DCGID} \
	docker-compose build --pull --no-cache install

install:
	DCUID=${DCUID} \
	DCGID=${DCGID} \
	docker-compose run --rm install

build:
	make cleanNg
	npm run doc
	DCUID=${DCUID} \
	DCGID=${DCGID} \
	NG_EXTRA="${NG_EXTRA}" \
	THPRO=${THPRO} \
	docker-compose run --rm --user=${DCUID}:${DCGID} build

release:
	make build NG_EXTRA="--prod=true ${NG_EXTRA}"

dev:
	make cleanNg
	DCUID=${DCUID} \
	DCGID=${DCGID} \
	NG_EXTRA="${NG_EXTRA}" \
	THPRO=${THPRO} \
	docker-compose run -p 8081:8081 --rm --user=${DCUID}:${DCGID} dev

devjit:
	make dev NG_EXTRA=-c=jit

testdev:
	make cleanNg
	DCUID=${DCUID} \
	DCGID=${DCGID} \
	NG_EXTRA="${NG_EXTRA}" \
	THPRO=1 \
	docker-compose up ${DOCKER_EXTRA} --remove-orphans --force-recreate --exit-code-from test test
	make down

tests:
	make testdev NG_EXTRA="--watch=false --progress=false"

e2etest:
	make cleanNg
	DCUID=${DCUID} \
 	DCGID=${DCGID} \
 	NG_EXTRA="${NG_EXTRA}" \
 	THPRO=1 \
 	HOST=${CI_TARGET_HOST} \
 	docker-compose up ${DOCKER_EXTRA} --remove-orphans --force-recreate --exit-code-from e2e e2e
	make down

down:
	docker-compose down
