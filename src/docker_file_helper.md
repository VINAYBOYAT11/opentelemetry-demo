# Dockerfile Helper for the OpenTelemetry Demo

This guide explains how Dockerfiles work in this repository and how to write a new one in the same simple style used by the service Dockerfiles.

The main idea is simple:

1. Find out what language the service uses.
2. Find out how that language is built and started.
3. Install dependencies.
4. Build the service when it needs compilation.
5. Copy only what is needed to run it.
6. Expose the same port that Compose gives to the service.
7. Start the service with the correct command.

---

## 1. What A Dockerfile Does

A Dockerfile is a list of instructions for building an image.

```dockerfile
FROM image-that-provides-the-language
WORKDIR /app
COPY files-from-the-repository ./
RUN command-used-during-the-build
EXPOSE service-port
ENTRYPOINT ["command-used-when-the-container-starts"]
```

There are two different moments to understand:

- **Build time:** Docker creates the image. Dependency installation, compilation, code generation, and tests happen here.
- **Runtime:** The container starts. The final application command runs here.

A command used only to prepare the application belongs in `RUN`. The command that keeps the service running belongs in `CMD` or `ENTRYPOINT`.

Example:

```dockerfile
RUN dotnet publish -c Release -o /app/publish
ENTRYPOINT ["./Accounting"]
```

The first command builds the application. The second command starts it.

---

## 2. How To Choose The Base Image

Start with the language and its version. Use an official image that already contains the compiler or runtime.

| Language or tool | Build image used in this project | Runtime image used in this project |
|---|---|---|
| C# / .NET | `mcr.microsoft.com/dotnet/sdk:10.0` | `mcr.microsoft.com/dotnet/aspnet:10.0` |
| Java | `eclipse-temurin:21-jdk` | `eclipse-temurin:21-jre` |
| Kotlin | `eclipse-temurin:17-jdk` | `eclipse-temurin:21-jre` |
| Go | `golang:1.27-alpine` or `golang:1.27.0-bookworm` | `gcr.io/distroless/static-debian12:nonroot` or another small runtime |
| Rust | `rust:1.98.0` | `gcr.io/distroless/cc-debian13:nonroot` |
| Python | `python:3.14-slim` | Python itself, often with a copied virtual environment |
| Ruby | `ruby:3.4` | `ruby:3.4-slim` |
| PHP | Composer and PHP images | `php:8.5-cli-alpine3.24` |
| Node.js | `node:25` or `node:26` | Node.js or a distroless Node image |
| C++ | C++ development image | `ubuntu` with only runtime libraries |
| Elixir | `elixir:1.20` | `elixir:1.20-slim` |

Use a version that matches the service configuration. Do not choose a newer version just because it exists. The application, lock files, build files, and Compose configuration must agree.

This project uses readable image tags. Do not add `@sha256` image digests when following the local Dockerfile style.

---

## 3. Compiled Or Interpreted?

This decision tells you whether you need a build stage.

### Compiled services

Go, Rust, C++, .NET, Java, and Kotlin normally compile or package the application before it runs.

A typical pattern is:

```dockerfile
FROM compiler-image AS build
WORKDIR /app
COPY service-files ./
RUN build-command

FROM smaller-runtime-image
WORKDIR /app
COPY --from=build /app/output ./
ENTRYPOINT ["./application"]
```

The first image has compilers and build tools. The second image contains only the application and the libraries needed at runtime.

Examples in this repository:

- `dotnet publish` creates the Accounting output.
- `gradlew shadowJar` creates the Fraud Detection JAR.
- `go build` creates the Checkout and Product Catalog binaries.
- `cargo build -r` creates the Shipping binaries.

### Interpreted services

Python, Ruby, PHP, and some Node.js services run through a language runtime. They still need their dependencies installed in the image.

```dockerfile
FROM python:3.14-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --require-hashes -r requirements.txt
COPY service-source ./
CMD ["python", "run.py"]
```

Some interpreted services still use two stages. For example, Recommendation creates a virtual environment in a build stage and copies it into the runtime image.

---

## 4. Multi-Stage Builds

Use a second stage when the compiler, package manager, or build tools are not needed after the build.

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app
COPY ./src/accounting/ ./
COPY ./pb/demo.proto ./src/protos/demo.proto
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish/ ./
ENTRYPOINT ["./Accounting"]
```

`COPY --from=build` means: copy files from the earlier build stage, not from the host machine.

Keep a single-stage Dockerfile when the service is already a small runtime image or when the build tools are also required to run the service. Keep the file easy to understand; do not add stages only for decoration.

---

## 5. Copy Files In The Right Order

Copy dependency files before source files. Docker can then reuse the dependency layer when only application code changes.

Good pattern:

```dockerfile
COPY ./src/payment/package.json package.json
COPY ./src/payment/package-lock.json package-lock.json
RUN npm ci --omit=dev
COPY ./src/payment/charge.js charge.js
COPY ./src/payment/index.js index.js
```

For each language, copy the dependency files first:

- Node.js: `package.json`, `package-lock.json`
- Python: `requirements.txt`
- Ruby: `Gemfile`, `Gemfile.lock`
- Go: `go.mod`, `go.sum`
- .NET: project files and package property files
- Java or Kotlin: Gradle files and the Gradle wrapper
- PHP: `composer.json`, and normally `composer.lock`
- Rust: `Cargo.toml`, `Cargo.lock`

After dependencies are installed, copy the source code and build it.

---

## 6. Docker Compose Is Part Of The Contract

This repository normally builds with the repository root as the build context:

```yaml
services:
  payment:
    build:
      context: ./
      dockerfile: ${PAYMENT_DOCKERFILE}
```

That means a Dockerfile can use paths such as:

```dockerfile
COPY ./src/payment/index.js index.js
COPY ./pb/demo.proto demo.proto
```

Do not assume the Dockerfile directory is the build context. Check the service in `compose.yaml` first.

Before finishing a Dockerfile, compare it with Compose:

- Is the `dockerfile` path correct?
- Is the build `context` correct?
- Does the Dockerfile use every required build argument?
- Does the image listen on the port in the Compose environment?
- Does the `ENTRYPOINT` or `CMD` start the command expected by the service?
- Does the Compose healthcheck find the required executable?
- Does the service need a mounted file such as `/otel-config.yml`?
- Does the service depend on a generated protobuf file or shared source file?

Validate all Compose overlays with:

```bash
docker compose \
  -f compose.yaml \
  -f compose.full.yaml \
  -f compose.observability.yaml \
  -f compose.agent.yaml \
  -f compose.tests.yaml \
  config --quiet
```

No output means the Compose configuration is valid.

---

## 7. Ports And Environment Variables

`EXPOSE` documents the port used by the image. It does not publish the port to the host by itself.

```dockerfile
EXPOSE ${PAYMENT_PORT}
```

The actual value normally comes from Compose and the `.env` files. Use the same variable name in the Dockerfile and Compose service.

Do not hard-code a different port in the Dockerfile if the application reads a port from an environment variable.

Some services do not need `EXPOSE` in their Dockerfile because their Compose file already defines the port. Check the existing service pattern before adding one.

---

## 8. ENTRYPOINT And CMD

Use `ENTRYPOINT` when the container has one clear executable that should always run.

```dockerfile
ENTRYPOINT ["./docker-checkout"]
```

Use `CMD` when the image has a normal default command that Compose or another user may replace.

```dockerfile
CMD ["python", "run.py"]
```

Use the JSON form. It passes arguments correctly and avoids an extra shell process.

Some services must use a shell because they create a configuration file at startup. For example, the Envoy and nginx services run `envsubst` before starting their server. Do not replace those commands with a direct server command or the environment values will not be inserted into the configuration.

---

## 9. Service Patterns In This Repository

### .NET

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app
COPY ./src/service/ ./
COPY ./pb/demo.proto ./src/protos/demo.proto
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish/ ./
ENTRYPOINT ["./Service"]
```

### Go

```dockerfile
FROM golang:1.27-alpine AS build
WORKDIR /app
COPY ./src/service/go.mod ./src/service/go.sum ./
RUN go mod download
COPY ./src/service/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -o service

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=build /app/service ./service
ENTRYPOINT ["./service"]
```

### Python

```dockerfile
FROM python:3.14-slim
WORKDIR /app
COPY ./src/service/requirements.txt requirements.txt
RUN pip install --no-cache-dir --require-hashes -r requirements.txt
COPY ./src/service/ ./
CMD ["python", "run.py"]
```

### Node.js

```dockerfile
FROM node:26-slim AS build
WORKDIR /app
COPY ./src/service/package.json package.json
COPY ./src/service/package-lock.json package-lock.json
RUN npm ci --omit=dev
COPY ./src/service/ ./

FROM node:26-slim
WORKDIR /app
COPY --from=build /app ./
CMD ["index.js"]
```

### Java or Kotlin

```dockerfile
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app
COPY ./src/service/ ./
RUN chmod +x ./gradlew
RUN ./gradlew shadowJar --no-daemon

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/build/libs/*-all.jar ./service.jar
ENTRYPOINT ["java", "-jar", "./service.jar"]
```

---

## 10. Healthchecks And Special Files

A Dockerfile must include files that Compose expects to use.

Examples from this project:

- Product Catalog copies `/bin/grpc_health_probe` because Compose uses it in the healthcheck.
- Shipping copies both `shipping` and `healthcheck` binaries.
- Checkout needs its generated protobuf files and uses a gRPC health probe.
- Telemetry Docs must run Weaver before MkDocs so the pages match the telemetry schema.
- Frontend Proxy must render `envoy.tmpl.yaml` with `envsubst` before Envoy starts.
- Image Provider and Telemetry Docs must render nginx configuration at startup.
- Kafka needs the Java OpenTelemetry agent and the `OTEL_JAVA_AGENT_VERSION` build argument.

When simplifying a Dockerfile, never remove a file or command just because it looks unused. Check Compose, the service README, the application code, and healthchecks first.

---

## 11. A Simple Checklist

Before building:

- [ ] I know the language and required version.
- [ ] I know whether the service compiles or runs through a runtime.
- [ ] I found the dependency files.
- [ ] I know the build command.
- [ ] I know the runtime command.
- [ ] I know the service port.
- [ ] I checked the Compose build context.
- [ ] I checked build arguments and environment variables.
- [ ] I checked healthchecks and required helper files.
- [ ] I kept shared files such as `pb/demo.proto` when the service needs them.

After editing:

```bash
docker compose -f compose.yaml config --quiet
git diff --check
```

When the image itself is ready to be tested:

```bash
docker compose -f compose.yaml build service-name
docker compose -f compose.yaml up service-name
```

Replace `service-name` with the actual Compose service.

---

## 12. The Rule To Remember

Write the smallest Dockerfile that still contains everything the service needs at runtime.

Keep the steps visible:

```dockerfile
FROM ... AS build
WORKDIR /app
COPY dependencies ./
RUN install-dependencies
COPY source ./
RUN build-application

FROM ...
WORKDIR /app
COPY --from=build output ./
EXPOSE ${SERVICE_PORT}
ENTRYPOINT ["start-application"]
```

Simple does not mean incomplete. A good Dockerfile is easy for another person to read, easy for Compose to use, and honest about what the service needs to build and run.
