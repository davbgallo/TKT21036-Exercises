#!/bin/sh

GIT_REPO=$1
DOCKER_REPO=$2

GIT_BASE=$(basename "$GIT_REPO")

git -C $GIT_BASE pull || git clone git@github.com:$GIT_REPO.git

docker build $GIT_BASE -t $DOCKER_REPO:latest

docker push $DOCKER_REPO

exit 0
