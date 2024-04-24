docker build . -t 304
docker run -e DOCKER_USER=<username> -e DOCKER_PWD=<secret> -v /var/run/docker.sock:/var/run/docker.sock 304 github/repo dockerhub/repo
