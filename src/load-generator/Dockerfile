# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM docker.io/library/golang:1.26.6-bookworm AS builder
# Build k6 with the demo's OpenTelemetry extension.
RUN go install go.k6.io/xk6/cmd/xk6@v1.4.7
WORKDIR /build
COPY ./src/load-generator/xk6-otel ./xk6-otel

RUN xk6 build v2.1.0 \
    --with github.com/open-telemetry/opentelemetry-demo/src/load-generator/xk6-otel=./xk6-otel \
    --output ./k6

FROM docker.io/grafana/k6:2.2.0-with-browser
# Keep the browser image, but use the custom k6 binary built above.
COPY --from=builder /build/k6 /usr/bin/k6
WORKDIR /home/k6
COPY ./src/load-generator/script.js .
COPY ./src/load-generator/people.json .
COPY --chmod=755 ./src/load-generator/entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
