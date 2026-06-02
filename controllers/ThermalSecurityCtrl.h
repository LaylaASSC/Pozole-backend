#pragma once
#include <drogon/HttpController.h>
#include <mutex>
#include <string>
#include <vector>

using namespace drogon;

struct Historial {
    std::string zona;
    float temperatura;
    std::string tipo_alerta;
};

struct SensorTermico {
    int id_sensor;
    float temperatura_detectada = 0.0f;
    float temperatura_anterior = 0.0f;
    bool presencia_detectada = false;
    bool alerta_generada = false;
    std::string zona_monitoreada;
};

class ThermalSecurityCtrl : public drogon::HttpController<ThermalSecurityCtrl> {
public:
    METHOD_LIST_BEGIN
    ADD_METHOD_TO(ThermalSecurityCtrl::autorizar, "/api/seguridad/autorizar", Post);
    ADD_METHOD_TO(ThermalSecurityCtrl::monitorearZona, "/api/seguridad/monitorear", Post);
    ADD_METHOD_TO(ThermalSecurityCtrl::escanearGeneral, "/api/seguridad/escanear_general", Post);
    ADD_METHOD_TO(ThermalSecurityCtrl::estado, "/api/seguridad/estado", Get);
    ADD_METHOD_TO(ThermalSecurityCtrl::historial, "/api/seguridad/historial", Get);
    METHOD_LIST_END

    ThermalSecurityCtrl();

    void autorizar(const HttpRequestPtr& req, std::function<void(const HttpResponsePtr&)>&& callback);
    void monitorearZona(const HttpRequestPtr& req, std::function<void(const HttpResponsePtr&)>&& callback);
    void escanearGeneral(const HttpRequestPtr& req, std::function<void(const HttpResponsePtr&)>&& callback);
    void estado(const HttpRequestPtr& req, std::function<void(const HttpResponsePtr&)>&& callback);
    void historial(const HttpRequestPtr& req, std::function<void(const HttpResponsePtr&)>&& callback);

private:
    void guardarHistorial(const std::string& zona, float temp, const std::string& tipo);
    Json::Value generarAlerta(SensorTermico& sensor);

    std::vector<SensorTermico> sensores;
    std::vector<Historial> registro;
    bool acceso_autorizado = false;
    std::mutex mtx_;
};
