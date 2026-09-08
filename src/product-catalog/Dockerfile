# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0


FROM docker.io/library/golang:1.27.0-bookworm AS builder
WORKDIR /app

# Download Go packages before copying the source code.
COPY ./src/product-catalog/go.mod go.mod
COPY ./src/product-catalog/go.sum go.sum
RUN go mod download

COPY ./src/product-catalog/genproto/oteldemo/ genproto/oteldemo/
COPY ./src/product-catalog/flags/ flags/
COPY ./src/product-catalog/main.go main.go

RUN CGO_ENABLED=0 GOOS=linux GO111MODULE=on go build -ldflags "-s -w" -o product-catalog main.go

FROM ghcr.io/grpc-ecosystem/grpc-health-probe:v0.4.56 AS grpc-health-probe

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app

# Copy the service and the healthcheck used by Compose.
COPY --from=builder /app/product-catalog ./product-catalog
COPY --from=grpc-health-probe /ko-app/grpc-health-probe /bin/grpc_health_probe

EXPOSE ${PRODUCT_CATALOG_PORT}
ENTRYPOINT [ "./product-catalog" ]
