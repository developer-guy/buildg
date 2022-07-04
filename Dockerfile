# syntax = docker/dockerfile:1.4.0
FROM --platform=${BUILDPLATFORM} golang:1.18.3-stretch@sha256:a9718cb62e77cc03411ea11fd71f3541e508f211169dd8f8d69ba2036545cd80 AS base
WORKDIR /src
ENV CGO_ENABLED=0
COPY go.* .
# https://go.dev/ref/mod#module-cache
RUN --mount=type=cache,target=/go/pkg/mod go mod download

FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.1.1@sha256:23ca08d120366b31d1d7fad29283181f063b0b43879e1f93c045ca5b548868e9 AS xx

FROM base AS build

COPY --from=xx / /

ARG TARGETPLATFORM
# https://pkg.go.dev/cmd/go#hdr-Build_and_test_caching
RUN --mount=type=bind,target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
  xx-go build -o /out/example .

FROM scratch AS bin-unix
COPY --from=build /out/example /

ENTRYPOINT [ "/example"]
