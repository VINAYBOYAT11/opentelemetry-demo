# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0


FROM --platform=${BUILDPLATFORM} docker.io/library/rust:1.98.0 AS builder
ARG TARGETARCH
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo Building on ${BUILDPLATFORM} for ${TARGETPLATFORM}

# Install native tools for the selected target platform.
RUN apt-get update && \
    if [ "${TARGETPLATFORM}" = "linux/arm64" ] && [ "${BUILDPLATFORM}" != "linux/arm64" ] ; then \
        apt-get install --no-install-recommends -y g++-aarch64-linux-gnu libc6-dev-arm64-cross libprotobuf-dev protobuf-compiler ca-certificates && \
        rustup target add aarch64-unknown-linux-gnu; \
    else \
        apt-get install --no-install-recommends -y g++ libc6-dev libprotobuf-dev protobuf-compiler ca-certificates; \
    fi

WORKDIR /app/

COPY ./src/shipping/ ./

# Build both the service and its Compose healthcheck binary.
RUN if [ "${TARGETPLATFORM}" = "linux/arm64" ] && [ "${BUILDPLATFORM}" != "linux/arm64" ] ; then \
        env CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc \
            CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc \
            CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++ \
        cargo build -r --target aarch64-unknown-linux-gnu && \
        cp /app/target/aarch64-unknown-linux-gnu/release/shipping /app/target/release/shipping && \
        cp /app/target/aarch64-unknown-linux-gnu/release/healthcheck /app/target/release/healthcheck; \
    else \
        cargo build -r; \
    fi


FROM gcr.io/distroless/cc-debian13:nonroot
WORKDIR /app
COPY --from=builder /app/target/release/shipping ./shipping
COPY --from=builder /app/target/release/healthcheck ./healthcheck

EXPOSE ${SHIPPING_PORT}

CMD ["./shipping"]
