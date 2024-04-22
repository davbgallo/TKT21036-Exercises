FROM node:16

EXPOSE 5000

WORKDIR /usr/src/app

ENV REQUEST_ORIGIN="http://localhost:5000"
ENV REACT_APP_BACKEND_URL="http://localhost:8080"

COPY example-frontend/ .

RUN npm install; npm run build; npm install -g serve

CMD serve -s -l 5000 build


