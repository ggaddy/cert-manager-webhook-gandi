# syntax=docker/dockerfile:1.3
ARG GO_VERSION
FROM --platform=${TARGETPLATFORM} golang:${GO_VERSION}-alpine AS base

WORKDIR /go/src/cert-manager-webhook-gandi
COPY go.* .

RUN apk add --no-cache git ca-certificates && \
    go mod download

FROM base AS build
ARG TARGETOS
ARG TARGETARCH

COPY . .

RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -a -o /go/bin/webhook -ldflags '-w -extldflags "-static"' .

FROM scratch AS image
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /go/bin/webhook /usr/local/bin/webhook

ENTRYPOINT ["/usr/local/bin/webhook"]
