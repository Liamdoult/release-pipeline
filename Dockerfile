# Based on https://github.com/xesina/golang-echo-realworld-example-app/blob/master/Dockerfile
# Build Container
FROM golang:1.16 AS build

ENV GO111MODULE=on \
    GOOS=linux \
    GOARCH=amd64

RUN mkdir -p /src

# First add modules list to better utilize caching
COPY go.sum go.mod /src/

WORKDIR /src

# Download dependencies
RUN go mod download

COPY example_app/ /src

# Build components.
# Put built binaries and runtime resources in /app dir ready to be copied over or used.
RUN go install -installsuffix cgo -ldflags="-w -s" example_app && \
    mkdir -p /app && \
    cp -r $GOPATH/bin/example_app /app/

# Runtime Container
FROM golang:1.16-alpine

# See http://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

WORKDIR /app

COPY --from=build /app /app/

EXPOSE 8080 

CMD ["./example_app"]
