#pragma once
#include <drogon/HttpController.h>
#include <mutex>
#include <string>
#include <vector>

using namespace drogon;

struct Apartamento {
    std::string apartamento;
    std::string codigos_registrados;
    bool invitacion = false;
    bool bloqueado = false;
    int intentos_fallidos = 0;
};

class AccessControlCtrl : public drogon::HttpController<AccessControlCtrl> {
public:
    METHOD_LIST_BEGIN
    ADD_METHOD_TO(AccessControlCtrl::login, "/api/acceso/login", Post);
    ADD_METHOD_TO(AccessControlCtrl::registrarInvitacion, "/api/acceso/invitacion", Post);
    METHOD_LIST_END

    AccessControlCtrl();

    void login(const HttpRequestPtr& req, std::function<void(const HttpResponsePtr&)>&& callback);
    void registrarInvitacion(const HttpRequestPtr& req, std::function<void(const HttpResponsePtr&)>&& callback);

private:
    std::vector<Apartamento> apts;
    std::mutex mtx_;
};
