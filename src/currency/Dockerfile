# Use a C++ development image to compile the currency service.
FROM mcr.microsoft.com/devcontainers/cpp:latest AS build

# Compose provides the OpenTelemetry C++ version through this build argument.
ARG OPENTELEMETRY_CPP_VERSION=1.27.0

# Install the compiler, CMake, and libraries needed by the C++ project.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential \
		cmake \
		git \
		libgrpc++-dev \
		libprotobuf-dev \
		protobuf-compiler \
		protobuf-compiler-grpc \
		libcurl4-openssl-dev \
		libssl-dev \
		libre2-dev \
		zlib1g-dev \
		nlohmann-json3-dev \
	&& rm -rf /var/lib/apt/lists/*

# Build OpenTelemetry C++ so the currency service can find its CMake package.
RUN git clone --depth 1 --branch "v${OPENTELEMETRY_CPP_VERSION}" \
		https://github.com/open-telemetry/opentelemetry-cpp.git /tmp/opentelemetry-cpp \
	&& cmake -S /tmp/opentelemetry-cpp -B /tmp/opentelemetry-cpp/build \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_TESTING=OFF \
		-DWITH_EXAMPLES=OFF \
		-DWITH_OTLP_GRPC=ON \
		-DWITH_OTLP_HTTP=ON \
	&& cmake --build /tmp/opentelemetry-cpp/build --parallel \
	&& cmake --install /tmp/opentelemetry-cpp/build \
	&& rm -rf /tmp/opentelemetry-cpp

WORKDIR /app

# The build context is the repository root, so copy only this service's files.
COPY src/currency/ ./

# Configure the project with CMake, then compile the currency executable.
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	&& cmake --build build --parallel

# Use a smaller image for running the already-built service.
FROM ubuntu:24.04

# Install the service's runtime libraries and netcat for Compose's healthcheck.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libgrpc++1.51 \
		libprotobuf32 \
		libcurl4 \
		libre2-10 \
		netcat-openbsd \
	&& rm -rf /var/lib/apt/lists/*

# Copy the OpenTelemetry shared libraries installed during the build stage.
COPY --from=build /usr/local/lib/ /usr/local/lib/

# Copy the compiled service from the build stage into the runtime image.
COPY --from=build /app/build/currency /usr/local/bin/currency

# Refresh the dynamic linker cache after adding OpenTelemetry libraries.
RUN ldconfig

# Compose configures the service to listen on port 7001.
EXPOSE 7001

# Start the service using the port supplied by Compose.
ENTRYPOINT ["/bin/sh", "-c", "exec /usr/local/bin/currency \"${CURRENCY_PORT:-7001}\""]


