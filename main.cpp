#include <drogon/drogon.h>

int main() {
    // Escuchar en el puerto 8080
    drogon::app().addListener("0.0.0.0", 8080);
    
    // Iniciar la app de Drogon
    drogon::app().run();
    return 0;
}
