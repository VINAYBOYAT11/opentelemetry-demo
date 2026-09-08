# Dockerfile Guide for flagd-ui

This document explains the Dockerfile for the `flagd-ui` service in simple terms.

## What is flagd-ui?

`flagd-ui` is a web application used to view and change feature flags.

It is built with:

- **Elixir**: the programming language.
- **Phoenix**: the web framework built with Elixir.
- **LiveView**: allows interactive web pages with server-side Elixir code.
- **Bandit**: the HTTP server used by Phoenix.
- **Tailwind**: builds the CSS files.
- **esbuild**: builds the JavaScript files.
- **OpenTelemetry**: sends application telemetry to an OpenTelemetry Collector.

The project configuration is in [mix.exs](mix.exs).

## What is a Dockerfile?

A Dockerfile is a list of instructions for building a Docker image.

An image contains the files and software needed to run an application. A
container is a running instance of that image.

A Dockerfile usually does two jobs:

1. Prepare tools and source code to build the application.
2. Define how the finished application starts.

## Important Docker terms

### Image

An image is a packaged filesystem. It contains the application, libraries, and
runtime needed by the application.

### Container

A container is a running image. Containers are isolated processes, but they can
communicate through networks, ports, and mounted files.

### Build context

The build context is the directory whose files Docker is allowed to read with
`COPY`.

This project is built by Compose with the repository root as the context:

```yaml
build:
  context: ./
```

Therefore, this Dockerfile uses paths such as:

```dockerfile
COPY ./src/flagd-ui/lib ./lib
```

Build from the repository root, not from `src/flagd-ui`:

```sh
docker build -f src/flagd-ui/Dockerfile -t flagd-ui .
```

The final dot means: use the current repository directory as the build context.

### Layer

Each Dockerfile instruction creates a layer. Docker can reuse unchanged layers
from an earlier build. This is why dependency files are copied before the rest
of the source code.

### Environment variable

An environment variable is a value supplied to the application at build time or
when the container starts.

Examples used by this service include:

```text
MIX_ENV
PHX_SERVER
FLAGD_UI_PORT
SECRET_KEY_BASE
OTEL_EXPORTER_OTLP_ENDPOINT
PHX_HOST
```

## Elixir and Mix basics

### Elixir

Elixir is the language used by this application. Elixir applications run on the
BEAM virtual machine, the same virtual machine used by Erlang.

The BEAM is designed for concurrent, fault-tolerant applications. Phoenix uses
these features to handle many web connections.

### Mix

Mix is Elixir's build tool. It is similar to tools such as npm, Maven, or
Gradle in other ecosystems.

Mix can:

- Download dependencies.
- Compile Elixir source code.
- Build frontend assets.
- Run tests.
- Create a production release.

### mix.exs

`mix.exs` is the main project definition file. It declares:

- The application name: `flagd_ui`.
- The Elixir version requirement.
- The project dependencies.
- The production release name: `flagd_ui`.
- Short command aliases such as `assets.deploy`.

### mix.lock

`mix.lock` records exact dependency versions. Copying it into the Docker build
makes dependency installation repeatable.

### MIX_ENV=prod

```dockerfile
ENV MIX_ENV=prod
```

This tells Mix to build the production version of the application. Development
and test-only dependencies are excluded from the production dependency build.

## Explanation of the Dockerfile

### Build stage

```dockerfile
FROM elixir:1.20 AS build
```

`FROM` selects the base image. This image contains Elixir and the Erlang/OTP
runtime.

`AS build` gives this stage a name. The name is used later when copying the
compiled release into the runtime stage.

This stage contains build tools and source code. It is not the final image.

### Working directory

```dockerfile
WORKDIR /app
```

All following commands run from `/app` inside the image. Files copied into `./`
are placed under `/app`.

### Copy dependency files

```dockerfile
COPY ./src/flagd-ui/mix.exs ./src/flagd-ui/mix.lock ./
COPY ./src/flagd-ui/config ./config
```

These commands copy the project definition and configuration into the image.

They are copied before the application source so Docker can reuse the dependency
layers when only application code changes.

### Download dependencies

```dockerfile
RUN mix deps.get --only prod
```

`RUN` executes a command while building the image.

This command downloads the dependencies required for production. The dependency
list is defined in `mix.exs`, and the locked versions come from `mix.lock`.

```dockerfile
RUN mix deps.compile
```

This compiles the downloaded dependencies.

### Copy application files

```dockerfile
COPY ./src/flagd-ui/assets ./assets
COPY ./src/flagd-ui/lib ./lib
COPY ./src/flagd-ui/priv ./priv
COPY ./src/flagd-ui/rel ./rel
COPY ./src/flagd-ui/.formatter.exs ./
```

These directories contain the application:

- `assets`: CSS and JavaScript source files.
- `lib`: Elixir application and Phoenix code.
- `priv`: static files and production resources.
- `rel`: release scripts, including the `bin/server` startup script.
- `.formatter.exs`: Elixir formatting configuration.

### Copy feature-flag data

```dockerfile
COPY ./src/flagd/demo.flagd.json ./data/demo.flagd.json
```

This copies the initial feature-flag configuration into `/app/data` inside the
build image.

The production configuration expects the file at:

```text
/app/data/demo.flagd.json
```

The application can read and update this file while it is running.

### Build frontend assets

```dockerfile
RUN mix assets.deploy
```

This project defines `assets.deploy` in `mix.exs`. It runs the production asset
commands:

- Tailwind builds and minifies CSS.
- esbuild bundles and minifies JavaScript.
- Phoenix creates a digest and cache manifest for static files.

The asset step must happen before the release is created.

### Compile the application

```dockerfile
RUN mix compile
```

This compiles the Elixir source code in `lib` into BEAM bytecode.

### Create the release

```dockerfile
RUN mix release
```

This creates a production release under:

```text
_build/prod/rel/flagd_ui
```

A release contains the compiled application and the files needed to run it.
The runtime image does not need the original source code or Mix project files.

## Runtime stage

```dockerfile
FROM elixir:1.20-slim AS runtime
```

This starts a new image stage. Only files explicitly copied from the build stage
are included.

The `slim` image is smaller than the normal Elixir image, but it still contains
Elixir. It is convenient for learning and debugging. A minimal production image
could use a Debian runtime image instead, but it may need additional runtime
libraries.

### Copy the release

```dockerfile
COPY --from=build /app/_build/prod/rel/flagd_ui ./
```

`--from=build` copies files from the earlier build stage.

This copies the compiled `flagd_ui` release into `/app` in the runtime image.

```dockerfile
COPY --from=build /app/data ./data
```

This copies the initial feature-flag data into the runtime image.

### Runtime environment

```dockerfile
ENV MIX_ENV=prod
ENV PHX_SERVER=true
```

`MIX_ENV=prod` tells the release that it is running in production.

`PHX_SERVER=true` tells the Phoenix endpoint to start its HTTP server. The
`bin/server` script also sets this value, so keeping it here makes the setting
explicit.

The application reads other production settings when the container starts:

```text
SECRET_KEY_BASE
OTEL_EXPORTER_OTLP_ENDPOINT
FLAGD_UI_PORT
PHX_HOST
```

Do not put real secrets directly in a Dockerfile. Supply them through Compose,
Docker secrets, or environment variables at runtime.

### Document the port

```dockerfile
EXPOSE 4000
```

This documents that the application normally listens on port `4000`.

`EXPOSE` does not publish the port to the host by itself. Port publishing is
configured by Compose or with `docker run -p`.

### Start the application

```dockerfile
CMD ["bin/server"]
```

`CMD` defines the default command when the container starts.

The `bin/server` script runs the compiled release and enables the Phoenix HTTP
server:

```sh
PHX_SERVER=true exec ./flagd_ui start
```

## Compose configuration

Compose builds this service from the repository root and supplies runtime
configuration:

```yaml
flagd-ui:
  build:
    context: ./
    dockerfile: ${FLAGD_UI_DOCKERFILE}
  environment:
    - FLAGD_UI_PORT
    - OTEL_EXPORTER_OTLP_ENDPOINT=http://${OTEL_COLLECTOR_HOST}:${OTEL_COLLECTOR_PORT_HTTP}
    - OTEL_SERVICE_NAME=flagd-ui
    - SECRET_KEY_BASE=...
    - PHX_HOST=localhost
  ports:
    - "${FLAGD_UI_PORT}"
```

The important difference is:

- `EXPOSE 4000` documents the container port.
- Compose `ports` publishes the port for access from the host.
- `environment` provides settings when the application starts.

## Useful commands

Run these commands from the repository root.

### Build the image

```sh
docker build -f src/flagd-ui/Dockerfile -t flagd-ui .
```

- `docker build`: build an image.
- `-f`: select the Dockerfile.
- `-t flagd-ui`: give the image a name.
- `.`: use the repository root as the build context.

### Check Dockerfile syntax

```sh
docker build --check -f src/flagd-ui/Dockerfile .
```

### Build with Compose

```sh
docker compose build flagd-ui
```

### Start with Compose

```sh
docker compose up flagd-ui
```

### Start in the background

```sh
docker compose up -d flagd-ui
```

### View logs

```sh
docker compose logs -f flagd-ui
```

### Stop the service

```sh
docker compose stop flagd-ui
```

## Simple build flow

The complete flow is:

```text
Repository source code
        |
        v
Build stage: install dependencies and compile assets
        |
        v
mix release: create _build/prod/rel/flagd_ui
        |
        v
Runtime stage: copy only the release
        |
        v
bin/server: start Phoenix
        |
        v
Container listens on port 4000
```

## Common errors

### `COPY failed: file not found`

You probably used the wrong build context. Run the build from the repository
root and keep the final `.` in the command:

```sh
docker build -f src/flagd-ui/Dockerfile -t flagd-ui .
```

### `release flagd_ui does not exist`

Check that the release was created with:

```sh
mix release
```

The directory name must be:

```text
_build/prod/rel/flagd_ui
```

### Missing `SECRET_KEY_BASE`

Production startup requires this environment variable. Compose supplies it, or
you can provide it manually:

```sh
docker run -e SECRET_KEY_BASE="a-long-secret" ... flagd-ui
```

### Missing OpenTelemetry endpoint

Production configuration also requires:

```text
OTEL_EXPORTER_OTLP_ENDPOINT
```

Set it to the address of the OpenTelemetry Collector.

### Container starts but the page is unavailable

Check that:

1. The container is running.
2. Port `4000` is published.
3. `FLAGD_UI_PORT` matches the port used by Compose.
4. The logs do not show a missing runtime environment variable.
5. The Compose healthcheck has the required `bash` command available.
