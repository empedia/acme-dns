FROM golang:alpine AS builder
LABEL maintainer="joona@kuori.org"

RUN apk add --update gcc musl-dev git

ENV GOPATH /tmp/buildcache

RUN git clone -b add-socat https://github.com/empedia/acme-dns /tmp/acme-dns
WORKDIR /tmp/acme-dns

RUN CGO_ENABLED=1 go build -o /usr/local/bin/acme-dns/acme-dns .

FROM alpine:latest

RUN mkdir -p /etc/acme-dns
RUN mkdir -p /var/lib/acme-dns
RUN mkdir -p /usr/local/bin/acme-dns

RUN apk --no-cache add ca-certificates && update-ca-certificates
RUN apk add --no-cache socat
RUN apk add --no-cache nano

VOLUME ["/etc/acme-dns", "/var/lib/acme-dns"]

COPY --from=builder /usr/local/bin/acme-dns/acme-dns /usr/local/bin/acme-dns/acme-dns
COPY --from=builder /tmp/acme-dns/startup.sh /usr/local/bin/acme-dns/startup.sh

RUN chmod +x /usr/local/bin/acme-dns/startup.sh

WORKDIR /etc/acme-dns

EXPOSE 53 80 443
EXPOSE 53/udp

CMD ["/usr/local/bin/acme-dns/startup.sh"]


