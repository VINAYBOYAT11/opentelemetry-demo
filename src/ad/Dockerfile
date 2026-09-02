# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM eclipse-temurin:21-jdk AS build
WORKDIR /app
COPY ./src/ad/ ./
COPY ./pb/ ./proto
RUN chmod +x ./gradlew
RUN ./gradlew installDist -PprotoSourceDir=./proto

FROM eclipse-temurin:21-jre AS runtime
WORKDIR /app



COPY --from=build /app/build/install/opentelemetry-demo-ad/ ./

ENV AD_PORT=8082
ENV AD_PROMETHEUS_PORT=9465
EXPOSE ${AD_PORT}
EXPOSE ${AD_PROMETHEUS_PORT}
ENTRYPOINT [ "./bin/Ad" ]