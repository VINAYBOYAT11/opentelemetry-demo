# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0


FROM docker.io/library/node:26.4.0-slim AS builder
WORKDIR /app

# Install the production packages used by the payment service.
COPY ./src/payment/package.json package.json
COPY ./src/payment/package-lock.json package-lock.json
RUN npm ci --omit=dev

FROM gcr.io/distroless/nodejs22-debian12:nonroot
WORKDIR /app

# Copy the service files into the small runtime image.
COPY --from=builder /app/node_modules/ node_modules/
COPY ./pb/demo.proto demo.proto

COPY ./src/payment/charge.js charge.js
COPY ./src/payment/index.js index.js
COPY ./src/payment/logger.js logger.js

EXPOSE ${PAYMENT_PORT}

CMD ["index.js"]
