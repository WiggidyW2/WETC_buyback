FROM rust:1.68-bullseye
WORKDIR /root/WETC_buyback_backend/
COPY ./WETC_buyback_backend/src src
COPY ./WETC_buyback_backend/proto proto
COPY ./WETC_buyback_backend/build.rs .
COPY ./WETC_buyback_backend/Cargo.toml .
RUN apt update
RUN apt install protobuf-compiler -y
RUN cargo build --release --features service --bin service

FROM golang:1.20-bullseye
WORKDIR /root/WETC_parser/
COPY ./WETC_parser/go.mod .
COPY ./WETC_parser/go.sum .
COPY ./WETC_parser/main.go .
RUN go build -o parser.exe .

FROM frolvlad/alpine-glibc:alpine-3.17
WORKDIR /root/
COPY --from=0 /root/WETC_buyback_backend/target/release/service bin
COPY --from=1 /root/WETC_parser/parser.exe .
RUN chmod +x ./bin
CMD ["./bin"]
