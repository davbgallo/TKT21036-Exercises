FROM node:16-alpine AS base

WORKDIR /usr/src/app

ENV REQUEST_ORIGIN="http://localhost:5000"
ENV REACT_APP_BACKEND_URL="http://localhost:8080"

COPY example-frontend/ .

RUN npm install; npm run build


FROM node:16-alpine AS release

WORKDIR /usr/src/app

EXPOSE 5000

COPY --from=base /usr/src/app/build ./build

RUN npm install -g serve

CMD serve -s -l 5000 build


