# =============================================
# Etapa 1: BUILD
# =============================================
FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    git \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libjsoncpp-dev \
    uuid-dev \
    libbrotli-dev \
    libares-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Compilar Drogon desde fuente
WORKDIR /deps
RUN git clone --depth=1 --recurse-submodules https://github.com/drogonframework/drogon.git && \
    cd drogon && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_CTL=OFF \
        -DBUILD_ORM=OFF \
        -DCMAKE_DISABLE_FIND_PACKAGE_Hiredis=ON && \
    make -j$(nproc) && \
    make install

# Compilar el backend
WORKDIR /app
COPY . .
RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

# =============================================
# Etapa 2: RUNTIME
# =============================================
FROM debian:bookworm-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    zlib1g \
    libjsoncpp25 \
    libbrotli1 \
    libcares2 \
    libuuid1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/build/PozoleBackend .

ENV PORT=8080
EXPOSE 8080

CMD ["/app/PozoleBackend"]
