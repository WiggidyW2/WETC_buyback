FROM rust:1.68-bullseye
WORKDIR /root/WETC_buyback_backend/
COPY ./WETC_buyback_backend/src src
COPY ./WETC_buyback_backend/proto proto
COPY ./WETC_buyback_backend/build.rs .
COPY ./WETC_buyback_backend/Cargo.toml .
RUN apt update
RUN apt install protobuf-compiler -y
RUN cargo build --release --bin shell

FROM golang:1.20-bullseye
WORKDIR /root/WETC_parser/
COPY ./WETC_parser/go.mod .
COPY ./WETC_parser/go.sum .
COPY ./WETC_parser/main.go .
RUN go build -o parser.exe .

FROM frolvlad/alpine-glibc:alpine-3.17
WORKDIR /root/
COPY --from=0 /root/WETC_buyback_backend/target/release/wetc_buyback_backend backend.exe
COPY --from=1 /root/WETC_parser/parser.exe .
COPY ./WETC_buyback_discord/main.py .
# Install python and python dependencies
RUN apk add --no-cache python3 py3-pip
RUN pip3 install --no-cache-dir discord
# Remove pip3 and APK
# RUN apk del py3-pip
# RUN rm -rf /root/.cache/pip3
# RUN rm -f /sbin./apk
# RUN rm -rf /etc/apk
# RUN rm -rf /lib/apk
# RUN rm -rf /usr/share/apk
# RUN rm -rf /var/lib/apk
RUN chmod +x ./main.py
CMD ["./main.py"]
