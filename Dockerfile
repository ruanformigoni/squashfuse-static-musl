FROM alpine:latest

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/main/ > /etc/apk/repositories
RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories

RUN apk update && apk upgrade

RUN apk add --no-cache git build-base autoconf automake libtool \
  pkgconfig zstd-dev zstd-libs zstd-static xz-dev xz-libs xz-static \
  lz4-dev lz4-libs lz4-static zlib-dev zlib-static fuse3-dev fuse3-static \
  upx

RUN git clone https://github.com/ruanformigoni/squashfuse-static-musl.git

WORKDIR squashfuse-static-musl

RUN LDFLAGS="-static"
RUN CFLAGS="-Wl,-static -no-pie"
RUN CXXFLAGS="-Wl,-static -no-pie"

# Static libgcc
RUN cd /usr/lib/gcc/x86_64-alpine-linux-musl/* && ln -s $(pwd)/libgcc.a $(pwd)/libgcc_s.a

RUN ./autogen.sh
RUN ./configure --enable-static --disable-shared LDFLAGS="-static"
RUN make -j"$(nproc)"

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded squashfuse

# Compress
RUN upx --ultra-brute --no-lzma squashfuse
