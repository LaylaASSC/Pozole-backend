# =============================================
# Single-stage: Ubuntu 22.04 con paquetes correctos
# =============================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Paquetes exactos de la documentación oficial de Drogon para Ubuntu 22.04
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    g++ \
    cmake \
    make \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libjsoncpp-dev \
    uuid-dev \
    libcares-dev \
    && rm -rf /var/lib/apt/lists/*

# Compilar Drogon desde fuente (sin brotli ni hiredis)
WORKDIR /deps
RUN git clone --depth=1 --recurse-submodules https://github.com/drogonframework/drogon.git && \
    cd drogon && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_CTL=OFF \
        -DBUILD_ORM=OFF \
        -DCMAKE_DISABLE_FIND_PACKAGE_Hiredis=ON \
        -DCMAKE_DISABLE_FIND_PACKAGE_Brotli=ON && \
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
