#include <drogon/drogon.h>
#include <cstdlib>
#include <string>

int main() {
    // Render asigna el puerto mediante la variable de entorno PORT
    const char* portEnv = std::getenv("PORT");
    int port = portEnv ? std::stoi(std::string(portEnv)) : 8080;

    // Permitir CORS para el frontend (acepta cualquier origen)
    drogon::app().registerPreHandlingAdvice(
        [](const drogon::HttpRequestPtr& req,
           std::function<void(const drogon::HttpResponsePtr&)>&& stop,
           std::function<void()>&& next) {
            // Manejar peticiones preflight OPTIONS (CORS)
            if (req->method() == drogon::Options) {
                auto resp = drogon::HttpResponse::newHttpResponse();
                resp->addHeader("Access-Control-Allow-Origin", "*");
                resp->addHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
                resp->addHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
                resp->setStatusCode(drogon::k204NoContent);
                stop(resp);
            } else {
                next();
            }
        }
    );

    drogon::app().registerPostHandlingAdvice(
        [](const drogon::HttpRequestPtr&, const drogon::HttpResponsePtr& resp) {
            resp->addHeader("Access-Control-Allow-Origin", "*");
            resp->addHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
            resp->addHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        }
    );

    drogon::app()
        .addListener("0.0.0.0", port)
        .run();

    return 0;
}
