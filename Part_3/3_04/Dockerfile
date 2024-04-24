FROM docker:25-git

WORKDIR /app

COPY builder.sh .
RUN chmod +x ./builder.sh

ENTRYPOINT ["./builder.sh"]
