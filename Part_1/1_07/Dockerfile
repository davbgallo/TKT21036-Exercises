FROM ubuntu:22.04

RUN apt update && apt install curl -y

COPY script.sh .
RUN chmod +x script.sh

CMD ./script.sh
