# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM docker.io/library/golang:1.27.0-alpine
WORKDIR /build
RUN apk add --no-cache protobuf-dev
COPY ./src/checkout/go.mod go.mod
COPY ./src/checkout/go.sum go.sum
RUN go install tool
