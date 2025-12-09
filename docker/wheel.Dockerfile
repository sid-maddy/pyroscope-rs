ARG BASE=manylinux2014
ARG PLATFORM=x86_64

FROM quay.io/pypa/${BASE}_${PLATFORM} AS builder
ARG BASE

ENV RUST_VERSION=1.87

RUN curl https://static.rust-lang.org/rustup/dist/$(arch)-unknown-linux-musl/rustup-init -o ./rustup-init \
    && chmod +x ./rustup-init \
    && ./rustup-init  -y --default-toolchain=${RUST_VERSION} --default-host=$(arch)-unknown-linux-gnu
ENV PATH=/root/.cargo/bin:$PATH

WORKDIR /pyroscope-rs

ADD Cross.toml \
    rustfmt.toml \
    Cargo.toml \
    Cargo.lock \
    ./

ADD src src
ADD pyroscope_backends pyroscope_backends
ADD pyroscope_ffi/ pyroscope_ffi/
RUN cd /pyroscope-rs/pyroscope_ffi/python && \
    [[ "$BASE" == manylinux* ]] && ./manylinux.sh || ./musllinux.sh

FROM scratch
COPY --from=builder /pyroscope-rs/pyroscope_ffi/python/dist dist/
