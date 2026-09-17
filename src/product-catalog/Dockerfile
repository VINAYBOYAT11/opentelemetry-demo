FROM golang:1.22-alpine AS builder

WORKDIR /usr/src/app/

# Use Go build cache for dependencies
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    mkdir -p /root/.cache/go-build

# Copy
COPY ./src/product-catalog/go.mod ./src/product-catalog/go.sum ./

# Download
RUN go mod download

# Copy the rest of the source code
COPY ./src/product-catalog .

RUN go build -o product-catalog .

####################################

FROM alpine AS release

WORKDIR /usr/src/app/

COPY ./src/product-catalog/products/ ./products/
COPY --from=builder /usr/src/app/product-catalog/ ./

ENV PRODUCT_CATALOG_PORT=8088
ENTRYPOINT [ "./product-catalog" ]
