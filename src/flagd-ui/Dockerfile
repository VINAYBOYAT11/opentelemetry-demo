# Build the Phoenix application and create a production release.
FROM elixir:1.20 AS build

WORKDIR /app
ENV MIX_ENV=prod

# Copy project files needed to download dependencies.
COPY ./src/flagd-ui/mix.exs ./src/flagd-ui/mix.lock ./
COPY ./src/flagd-ui/config ./config

# Download and compile production dependencies.
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy the application source code and assets.
COPY ./src/flagd-ui/assets ./assets
COPY ./src/flagd-ui/lib ./lib
COPY ./src/flagd-ui/priv ./priv
COPY ./src/flagd-ui/rel ./rel
COPY ./src/flagd-ui/.formatter.exs ./

# Include the default feature-flag data file.
COPY ./src/flagd/demo.flagd.json ./data/demo.flagd.json

# Build CSS and JavaScript, then create the release.
RUN mix assets.deploy
RUN mix compile
RUN mix release


# Run the compiled application in a smaller image.
FROM elixir:1.20-slim AS runtime

WORKDIR /app

# Copy only the compiled release and its data file.
COPY --from=build /app/_build/prod/rel/flagd_ui ./
COPY --from=build /app/data ./data

# Enable production mode and the Phoenix web server.
ENV MIX_ENV=prod
ENV PHX_SERVER=true

# The application listens on port 4000 by default.
EXPOSE 4000

# Start the Phoenix release.
CMD ["bin/server"]