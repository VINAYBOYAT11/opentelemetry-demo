# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM envoyproxy/envoy:v1.39.0
WORKDIR /home/envoy
COPY ./src/frontend-proxy/envoy.tmpl.yaml envoy.tmpl.yaml

EXPOSE ${ENVOY_PORT}
EXPOSE ${ENVOY_ADMIN_PORT}
ENTRYPOINT ["/bin/sh", "-c", "envsubst < envoy.tmpl.yaml > envoy.yaml && envoy -c envoy.yaml;"]
