# =============================================
# Etapa 1: BUILD - Compila el binario C++
# =============================================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias de sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libjsoncpp-dev \
    uuid-dev \
    libcares-dev \
    libbrotli-dev \
    && rm -rf /var/lib/apt/lists/*

# Clonar y compilar Drogon desde fuente
WORKDIR /deps
RUN git clone --recurse-submodules https://github.com/drogonframework/drogon.git && \
    cd drogon && \
    mkdir build && cd build && \
    cmake .. -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_CTL=OFF \
        -DBUILD_ORM=OFF \
        -DCMAKE_DISABLE_FIND_PACKAGE_Hiredis=ON \
        -DCMAKE_DISABLE_FIND_PACKAGE_ZLIB=OFF && \
    ninja && ninja install

# Compilar el proyecto Pozole Backend
WORKDIR /app
COPY . .
RUN mkdir build && cd build && \
    cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release && \
    ninja

# =============================================
# Etapa 2: RUNTIME - Imagen final liviana
# =============================================
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# Instalamos los mismos paquetes exactos que en el builder (sin las herramientas de compilación)
RUN apt-get update && apt-get install -y \
    libssl-dev \
    zlib1g-dev \
    libjsoncpp-dev \
    uuid-dev \
    libcares-dev \
    libbrotli-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar el binario compilado desde la etapa de build
COPY --from=builder /app/build/PozoleBackend /app/PozoleBackend
COPY --from=builder /usr/local/lib/libdrogon.a /usr/local/lib/
COPY --from=builder /usr/local/lib/libtrantor.a /usr/local/lib/

# Render asigna el puerto via variable de entorno PORT
ENV PORT=8080
EXPOSE 8080

CMD ["/app/PozoleBackend"]
