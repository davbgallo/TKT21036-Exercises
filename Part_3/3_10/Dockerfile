FROM golang AS base
WORKDIR /app
COPY hello.go .
RUN go build hello.go;adduser user

FROM scratch
COPY --from=base /app/hello /app/hello
COPY --from=base /etc/passwd /etc/passwd
USER user
ENTRYPOINT ["/app/hello"]



