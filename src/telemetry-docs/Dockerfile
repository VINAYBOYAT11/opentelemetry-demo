# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM docker.io/otel/weaver:v0.25.1 AS registry-builder
WORKDIR /workspace
# Generate the documentation from the telemetry schema.
COPY telemetry-schema /workspace/telemetry-schema
COPY src/telemetry-docs/templates /workspace/templates
RUN /weaver/weaver registry generate \
    --registry=/workspace/telemetry-schema \
    --templates=/workspace/templates \
    markdown \
    /workspace/docs

RUN /weaver/weaver registry package \
    --registry=/workspace/telemetry-schema \
    --resolved-schema-uri=https://opentelemetry.io/schemas/1.40.0 \
    --output=/workspace/docs/schema \
    --v2

FROM docker.io/library/python:3.14.7-slim-bookworm AS site-builder
WORKDIR /app
# Turn the generated Markdown into a static website.
COPY src/telemetry-docs/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --require-hashes -r requirements.txt
COPY src/telemetry-docs/mkdocs.yml /app/mkdocs-base.yml
COPY --from=registry-builder /workspace/docs /app/docs
RUN mv /app/docs/mkdocs.yml /app/mkdocs.yml && \
    mkdocs build --clean

FROM docker.io/nginxinc/nginx-unprivileged:1.31.2-alpine3.23-otel
USER 101
# Serve the generated website with unprivileged nginx.
COPY --from=site-builder /app/site /static
COPY src/telemetry-docs/nginx.conf.template /nginx.conf.template

EXPOSE ${TELEMETRY_DOCS_PORT}

STOPSIGNAL SIGQUIT

CMD ["/bin/sh" , "-c" , "envsubst '$OTEL_COLLECTOR_HOST $OTEL_COLLECTOR_PORT_GRPC $OTEL_SERVICE_NAME $TELEMETRY_DOCS_PORT' < /nginx.conf.template > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"]
