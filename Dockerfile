# informaldev/hermes image
#
# Used for running hermes in docker containers

FROM rust:1.51 AS build-env

ARG TAG="v0.2.0"
WORKDIR /root

RUN git clone https://github.com/informalsystems/ibc-rs
RUN cd ibc-rs && git checkout $TAG && cargo build --release


FROM debian:buster-slim

RUN cp ./config.toml $HOME/.hermes/config.toml

RUN apt update && apt install -y vim jq && useradd -m hermes -s /bin/bash
WORKDIR /home/hermes
USER hermes:hermes


COPY --chown=0:0 --from=build-env /root/ibc-rs/target/release/hermes /usr/bin/hermes
FROM golang:1.14 as build
WORKDIR /go/src/github.com/FigureTechnologies/ibc-rs
COPY go.mod ./go.mod
COPY go.sum ./go.sum
COPY cmd ./cmd/
COPY internal ./internal/

RUN go build -o /go/bin/ibc-rs ./cmd/ibc-rs/main.go
COPY --from=build /go/bin/ibc-rs /
ENTRYPOINT ["/ibc-rs"]
