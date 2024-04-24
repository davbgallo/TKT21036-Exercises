FROM golang:1.16 AS base

WORKDIR /usr/src/app

COPY example-backend/ .

ENV REQUEST_ORIGIN="http://localhost:5000"

RUN CGO_ENABLED=0 go build


FROM scratch

WORKDIR /usr/src/app

EXPOSE 8080

COPY --from=base /usr/src/app/ /usr/src/app

#ENTRYPOINT ["/usr/src/app/server"]

CMD ["./server"]
