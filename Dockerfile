FROM alpine:latest

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
RUN ln -s /usr/lib/gcc/x86_64-alpine-linux-musl/13.2.1/libgcc.a /usr/lib/gcc/x86_64-alpine-linux-musl/13.2.1/libgcc_s.a

RUN ./autogen.sh
RUN ./configure --enable-static --disable-shared LDFLAGS="-static"
RUN make -j"$(nproc)"

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded squashfuse

# Compress
RUN upx --ultra-brute --no-lzma squashfuse
