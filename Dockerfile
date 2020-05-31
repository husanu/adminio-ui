FROM node:12 as build

LABEL maintainer="rzrbld <razblade@gmail.com>"

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

RUN \
    git clone https://github.com/rzrbld/adminio-ui && \
    cd adminio-ui && \
    npm install -g @angular/cli@9.1.6 && npm install

RUN rm -rf adminio-ui/dist/*
RUN cd /app/adminio-ui && npm run build


FROM nginx:1.17-alpine

ENV API_BASE_URL http://localhost:8080
ENV ADMINIO_PROD false
ENV ADMINIO_MULTI_BACKEND true
ENV ADMINIO_BACKENDS '[{"name":"myminio","url":"http://localhost:8080"},{"name":"local","url":"http://localhost:8081"},{"name":"not-myminio","url":"http://minio.example.com:8080"}]'

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/adminio-ui/dist /usr/share/nginx/html

EXPOSE 80

CMD ["/bin/sh",  "-c",  "envsubst < /usr/share/nginx/html/env.template > /usr/share/nginx/html/env.js && exec nginx -g 'daemon off;'"]
