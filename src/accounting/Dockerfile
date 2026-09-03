FROM mcr.microsoft.com/dotnet/sdk:10.0 as build
WORKDIR /app
COPY ./src/accounting/ ./
COPY ./pb/demo.proto ./src/protos/demo.proto
RUN dotnet publish -c Release -o /app/publish


FROM mcr.microsoft.com/dotnet/aspnet:10.0 as publish
WORKDIR /app
COPY --from=build /app/publish/ ./

ENTRYPOINT ["./Accounting"]