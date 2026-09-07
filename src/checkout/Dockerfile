FROM golang:1.27-alpine AS builder
WORKDIR /app
COPY ./src/checkout/go.mod ./src/checkout/go.sum ./
COPY ./pb .
RUN go mod download
COPY ./src/checkout/ .
RUN CGO_ENABLED=0 GOOS=linux go build  -o /docker-checkout
#disable c language and target linux OS only 


FROM builder AS run-test-stage
RUN go test -v ./...
FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /app
COPY --from=builder /docker-checkout /docker-checkout


EXPOSE ${CHECKOUT_PORT}

ENTRYPOINT ["/docker-checkout"]