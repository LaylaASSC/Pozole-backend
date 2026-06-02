# =============================================
# Etapa 1: BUILD - Usa imagen oficial de Drogon
# (Ya tiene todo compilado: drogon, jsoncpp, openssl, etc.)
# =============================================
FROM drogonframework/drogon:latest AS builder

WORKDIR /app
COPY . .

RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

# =============================================
# Etapa 2: RUNTIME - Copia solo el binario
# =============================================
FROM drogonframework/drogon:latest AS runtime

WORKDIR /app
COPY --from=builder /app/build/PozoleBackend .

# Render asigna el puerto vía variable de entorno PORT
ENV PORT=8080
EXPOSE 8080

CMD ["/app/PozoleBackend"]
