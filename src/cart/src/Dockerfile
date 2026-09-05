FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app
COPY ./src/cart/Directory.Build.props ./src/cart/
COPY ./src/cart/Directory.Packages.props ./src/cart/
COPY ./src/cart/src/cart.csproj ./src/cart/src/
COPY ./pb/ ./pb/
WORKDIR /app/src/cart/src
RUN dotnet restore
COPY ./src/cart/src/ ./
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish/ ./

ENV CART_PORT=7070
EXPOSE ${CART_PORT}

ENTRYPOINT ["./cart"]
