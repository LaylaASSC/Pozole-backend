# buildpack-deps:jammy = Ubuntu 22.04 con gcc, g++, cmake, git,
# make, libssl-dev, zlib1g-dev ya instalados.
# Solo necesitamos unos pocos paquetes extras.
FROM buildpack-deps:jammy AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Solo los paquetes que buildpack-deps NO incluye
RUN apt-get update && apt-get install -y \
    libjsoncpp-dev \
    uuid-dev \
    libcares-dev \
    && rm -rf /var/lib/apt/lists/*

# Compilar Drogon desde fuente
WORKDIR /deps
RUN git clone --depth=1 --recurse-submodules https://github.com/drogonframework/drogon.git && \
    cd drogon && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_CTL=OFF \
        -DBUILD_ORM=OFF \
        -DCMAKE_DISABLE_FIND_PACKAGE_Hiredis=ON \
        -DCMAKE_DISABLE_FIND_PACKAGE_Brotli=ON && \
    make -j$(nproc) && make install && ldconfig

# Compilar el backend
WORKDIR /app
COPY . .
RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

ENV PORT=8080
EXPOSE 8080
CMD ["/app/build/PozoleBackend"]
