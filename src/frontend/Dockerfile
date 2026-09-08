# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM docker.io/library/node:25.9.0-slim AS builder

WORKDIR /app

# Install everything needed to build the Next.js application.
COPY ./src/frontend/package.json package.json
COPY ./src/frontend/package-lock.json package-lock.json
RUN npm ci

COPY ./src/frontend/components/ components/
COPY ./src/frontend/gateways/ gateways/
COPY ./src/frontend/pages/ pages/
COPY ./src/frontend/protos/ protos/
COPY ./src/frontend/providers/ providers/
COPY ./src/frontend/services/ services/
COPY ./src/frontend/styles/ styles/
COPY ./src/frontend/types/ types/

COPY ./src/frontend/utils/enums/ utils/enums/
COPY ./src/frontend/utils/telemetry/ utils/telemetry/
COPY ./src/frontend/utils/imageLoader.js utils/imageLoader.js
COPY ./src/frontend/utils/Request.ts utils/Request.ts

COPY ./src/frontend/next.config.js next.config.js
COPY ./src/frontend/tsconfig.json tsconfig.json

RUN npm run build

FROM docker.io/library/node:25.9.0-slim AS deps
WORKDIR /app

# Install only the packages needed at runtime.
COPY ./src/frontend/package.json package.json
COPY ./src/frontend/package-lock.json package-lock.json
RUN npm ci --omit=dev

FROM gcr.io/distroless/nodejs24-debian13:nonroot
WORKDIR /app

# Run the built frontend with a small non-root image.
COPY --from=builder /app/.next/standalone/ ./
COPY --from=builder /app/.next/static/ .next/static/
COPY --from=deps /app/node_modules/ node_modules/
COPY ./src/frontend/public/ public/
COPY ./src/frontend/utils/telemetry/Instrumentation.js Instrumentation.js

EXPOSE ${FRONTEND_PORT}

CMD ["--require=./Instrumentation.js", "server.js"]
