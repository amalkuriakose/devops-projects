FROM nginx:alpine

RUN adduser -D nonroot

USER nonroot

COPY index.html /usr/share/nginx/html/index.html

COPY styles /usr/share/nginx/html/styles

COPY scripts /usr/share/nginx/html/scripts

EXPOSE 80