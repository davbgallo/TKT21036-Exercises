# TKT21036-Exercises
Exercises from course https://devopswithdocker.com/
## Exercises
[Part 1](Part_1/)

## Environment Information
OS: AlmaLinux release 9.3 (Shamrock Pampas Cat)
Docker info:
```
Client: Docker Engine - Community
 Version:    26.0.2
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.14.0
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.26.1
    Path:     /usr/libexec/docker/cli-plugins/docker-compose

Server:
 Server Version: 26.0.2
 Storage Driver: overlay2
  Backing Filesystem: xfs
  Supports d_type: true
  Using metacopy: false
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: systemd
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: e377cd56a71523140ca6ae87e30244719194a521
 runc version: v1.1.12-0-g51d5e94
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  cgroupns
 Kernel Version: 5.14.0-362.8.1.el9_3.x86_64
 Operating System: AlmaLinux 9.3 (Shamrock Pampas Cat)
 OSType: linux
 Architecture: x86_64
 CPUs: 2
 Total Memory: 3.562GiB
 Name: almalinux.lab
 ID: a1f47afd-bfab-4120-8eb8-b90989550d23
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false
```

## PART 1
### Defiitions and basic concepts
Basic run of a container: `docker container run hello-world` or `docker run hello-world`

#### Docker components
- CLI
- REST API
- Docker daemon

`docker container run` = CLI > REST API > Daemon

##### Maintenance
to remove an image you need to remove the container first!
**STOP CONTAINER > REMOVE CONTAINER > REMOVE IMAGE**
```
docker ps -a
docker stop $$CONTAINER ID$$
# OR YOU CAN USE
# docker rm $$CONTAINER ID$$ --force
docker rm $$CONTAINER ID$$
docker rm $$IMAGE$$
```
TIP: when you remove a container you can use the first character of the string, you don't need to type the whole ID.

To remove all stopped containers: `docker system prune`
To remove all images not attached to a container AND without a name: `docker image prune`
NB: If the images have a name, you need to add `-a`

some containers are not stopped by SIGTERM sent by stop, so we need to
```
docker kill $$CONTAINER$$
docker rm $$CONTAINER$$
```
#### Images
Image is a file that **NEVER** changes. It can be layered (e.g. using an image as a base for another image).
composed by registry/organisation/image:tag

To check local images available: `docker image ls`
to create an image you need a `Dockerfile`, parsed by `docker image build`
```
FROM <image>:<tag>

RUN <install some dependencies>

CMD <command that is executed on `docker container run`>
```

To download images without running them: `docker image pull`
to search for an image: `docker search`
By default it searches only on docker hub. To add Quay: `docker search quay.io/hello`
Tag are used to download specific version of an image: `docker pull ubuntu:22.04`
You can also use tags internally: `docker tag ubuntu:22.04 ubuntu:jammy_jellyfish`

##### Dockerfile
Dockerfile is simply a file that contains the build instructions for an image. You define what should be included in the image with different instructions. We'll learn about the best practices here by creating one.
Script example
```
cat <<'EOF' >> hello.sh
#!/bin/sh

echo "Hello, docker!"
EOF
chmod +x hello.sh
```

Dockerfile
```
cat <<'EOF' >> Dockerfile
# Start from the alpine image that is smaller but no fancy tools
FROM alpine:3.19

# Use /usr/src/app as our workdir. The following instructions will be executed in this location.
WORKDIR /usr/src/app

# Copy the hello.sh file from this directory to /usr/src/app/ creating /usr/src/app/hello.sh
COPY hello.sh .

# Alternatively, if we skipped chmod earlier, we can add execution permissions during the build.
# RUN chmod +x hello.sh

# When running docker run the command will be ./hello.sh
CMD ./hello.sh
EOF
```

To build the dockerfile: `docker build . -t hello-docker`
```
[+] Building 3.0s (8/8) FINISHED                                                                                                                                                               docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                     0.0s
 => => transferring dockerfile: 605B                                                                                                                                                                     0.0s
 => [internal] load metadata for docker.io/library/alpine:3.19                                                                                                                                           1.7s
 => [internal] load .dockerignore                                                                                                                                                                        0.0s
 => => transferring context: 2B                                                                                                                                                                          0.0s
 => [1/3] FROM docker.io/library/alpine:3.19@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b                                                                                     1.0s
...
 => [2/3] WORKDIR /usr/src/app                                                                                                                                                                           0.0s
...
 => [3/3] COPY hello.sh .                                                                                                                                                                                0.0s
...
 => exporting to image                                                                                                                                                                                   0.1s
 => => exporting layers                                                                                                                                                                                  0.0s
 => => writing image sha256:a625ba8818742437ed614a203fc7f8a10eaa248937482538cae6a49efa2513b9                                                                                                             0.0s
 => => naming to docker.io/library/hello-docker             
```
During the build we see from the output that there are three steps: [1/3], [2/3] and [3/3]. The steps here represent layers of the image so that each step is a new layer on top of the base image (alpine:3.19 in our case).

Layers have multiple functions. We often try to limit the number of layers to save on storage space but layers can work as a cache during build time. If we just edit the last lines of Dockerfile the build command can start from the previous layer and skip straight to the section that has changed. COPY automatically detects changes in the files, so if we change the hello.sh it'll run from step 3/3, skipping 1 and 2. This can be used to create faster build pipelines.

To copy files to an existing container or viceversa: `docker cp ./additional.txt $$CONTAINER_NAME$$:/usr/src/app/`
To see differences made in a container: `docker diff $$CONATINER_NAME$$`
After incorporating modifications to my Dockerfile: `docker build . -t hello-docker:v2`
NB: `CMD` instruction is not runned during build but at runtime!

We should always try to keep the most prone to change rows at the bottom, by adding the instructions to the bottom we can preserve our cached layers - this is a handy practice to speed up the build process when there are time-consuming operations like downloads in the Dockerfile
We need a way to have something before the command. Luckily we have a way to do this: we can use ENTRYPOINT to define the main executable and then Docker will combine our run arguments for it.

```
# Replacing CMD with ENTRYPOINT
ENTRYPOINT ["/usr/local/bin/yt-dlp"]
```
`docker run yt-dlp https://www.youtube.com/watch?v=XsqlHHTGQrw`
With ENTRYPOINT docker run now executed the combined /usr/local/bin/yt-dlp https://www.youtube.com/watch?v=uTZSILGTskA inside the container!

ENTRYPOINT vs CMD can be confusing - in a properly set up image, such as our yt-dlp, the command represents an argument list for the entrypoint. By default, the entrypoint in Docker is set as /bin/sh -c and this is passed if no entrypoint is set. This is why giving the path to a script file as CMD works: you're giving the file as a parameter to /bin/sh -c.

If an image defines both, then the CMD is used to give default arguments to the entrypoint. Let us now add a CMD to the Dockerfile:
```
ENTRYPOINT ["/usr/local/bin/yt-dlp"]

# define a default argument
CMD ["https://www.youtube.com/watch?v=Aa55RKWZxxI"]
```
In addition to all seen, there are two ways to set the ENTRYPOINT and CMD: exec form and shell form. We've been using the exec form where the command itself is executed. In shell form the command that is executed is wrapped with /bin/sh -c - it's useful when you need to evaluate environment variables in the command like $MYSQL_PASSWORD or similar.

In the shell form, the command is provided as a string without brackets. In the exec form the command and it's arguments are provided as a list (with brackets), see the table below:

#### Containers
Only contains what reqtuired to execute an application (e.g. python libs)
Isolated environment that communicate with host/each other via TCP/UDP

to list all running containers `docker container ls`. Add `-a` to list previously run containers
Alias: `docker ps`

When running a container add `-d` otherwise you can't interact with your shell
To interact with the container shell, you need `-it`
- `-t`: Creates a tty (eli5 another shell)
- `-i`: Forwards STDIN to the new created shell with `-t`
`docker run -d -it --name looper ubuntu sh -c 'while true; do date; sleep 1; done'`
To check if it is running, we can use `docker logs -f looper`

You can attach to the same contained process multiple times simultaneously, screen sharing style, or quickly view the progress of your detached process. You connect to the MAIN container process
NB: When you exit you are killing the container! You need to detach/attach with `CTRL-p CTRL-q`
`docker attach --no-stdin looper` will print only the STDOUT but we won't be able to interact with the shell

Docker exec make you run a command inside a container, and you can connect to a separate TTY, so when you exit you don't kill the container
`docker exec -it looper bash`

more info: https://stackoverflow.com/questions/30960686/difference-between-docker-attach-and-docker-exec/77997774#77997774

We can add `--rm` to a `docker run` command in order to autoclean the system when the container is stopped. We lose the ability to use `docker start` in the future
`docker run -d --rm -it --name looper-it ubuntu sh -c 'while true; do date; sleep 1; done'`

a volume is simply a folder (or a file) that is shared between the host machine and the container. If a file in volume is modified by a program that's running inside the container the changes are also saved from destruction when the container is shut down as the file exists on the host machine. This is the main use for volumes as otherwise all of the files wouldn't be accessible when restarting the container. Volumes also can be used to share files between containers and run programs that are able to load changed files.

If we wish to create a volume with only a single file we could also do that by pointing to it. For example -v "$(pwd)/material.md:/mydir/material.md" this way we could edit the material.md locally and have it change in the container (and vice versa). Note also that -v creates a directory if the file does not exist.

it is possible to map your host machine port to a container port. For example, if you map port 1000 on your host machine to port 2000 in the container, and then you send a message to http://localhost:1000 on your computer, the container will get that message if it's listening to its port 2000.

Opening a connection from the outside world to a Docker container happens in two steps:
- Exposing port: telling Docker that the container listens to a certain port. This doesn't do much, except it helps humans with the configuration.
- Publishing port:  Docker will map host ports to the container ports.

`-p <host-port>:<container-port>`
OR
`EXPOSE <port>`

To specify UDP: `-p <host-port>:<container-port>/udp``

**SECURITY**: Limit scope of ports (e.g. localhost). By default target is 0.0.0.0
`-p 127.0.0.1:3456:3000`

