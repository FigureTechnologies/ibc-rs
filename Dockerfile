# informaldev/hermes image
#
# Used for running hermes in docker containers

FROM rust:1.51 AS build-env

ARG TAG="v0.2.0"
WORKDIR /root

RUN git clone https://github.com/informalsystems/ibc-rs
RUN cd ibc-rs && git checkout $TAG && cargo build --release


FROM debian:buster-slim

RUN apt update && apt install -y vim jq && useradd -m hermes -s /bin/bash
WORKDIR /home/hermes
USER hermes:hermes
ENTRYPOINT /usr/bin/hermes

COPY --chown=0:0 --from=build-env /root/ibc-rs/target/release/hermes /usr/bin/hermes
