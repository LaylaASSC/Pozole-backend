# =============================================
# Single-stage: build y run en la misma imagen
# Más simple y confiable en Render
# =============================================
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libjsoncpp-dev \
    uuid-dev \
    libbrotli-dev \
    libcares-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Compilar Drogon desde fuente
WORKDIR /deps
RUN git clone --depth=1 --recurse-submodules https://github.com/drogonframework/drogon.git && \
    cd drogon && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_CTL=OFF \
        -DBUILD_ORM=OFF \
        -DCMAKE_DISABLE_FIND_PACKAGE_Hiredis=ON && \
    make -j$(nproc) && make install && \
    ldconfig

# Compilar el backend
WORKDIR /app
COPY . .
RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

ENV PORT=8080
EXPOSE 8080

CMD ["/app/build/PozoleBackend"]
