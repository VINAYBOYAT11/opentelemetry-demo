# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM golang:1.25-alpine AS builder
ARG OPAMP_GO_REF
# Download and build the requested OpAMP server version.
RUN apk add --no-cache git
WORKDIR /src/opamp-go
RUN git init && \
    git remote add origin https://github.com/open-telemetry/opamp-go.git && \
    git fetch --depth 1 origin ${OPAMP_GO_REF} && \
    git checkout FETCH_HEAD

RUN sed -i 's|href="/"|href="/opamp/"|g' internal/examples/html/html/agent.html && \
    awk ' \
      /Additional Configuration:/ { skip = "td"; next } \
      /<form action="\/rotate_client_cert"/ { skip = "form"; next } \
      /<h3>OpAMP Connection Settings<\/h3>/ { skip = "form"; next } \
      /<h3>Custom Messages<\/h3>/ { exit } \
      skip == "td" && /<\/td>/ { skip = ""; next } \
      skip == "form" && /<\/form>/ { skip = ""; next } \
      skip == "" { print } \
    ' internal/examples/html/html/agent.html > /tmp/agent.html && \
    mv /tmp/agent.html internal/examples/html/html/agent.html && \
    sed -i 's|"/agent?instanceid=|"/opamp/agent?instanceid=|g' \
      internal/examples/server/uisrv/ui.go

WORKDIR /src/opamp-go/internal/examples
RUN go build -trimpath -ldflags="-s -w" -o /opamp-server ./server

FROM alpine:3.22
# Add certificates for secure connections.
RUN apk add --no-cache ca-certificates
COPY --from=builder /opamp-server /opamp-server

EXPOSE 4320
EXPOSE 4321

ENTRYPOINT ["/opamp-server"]
