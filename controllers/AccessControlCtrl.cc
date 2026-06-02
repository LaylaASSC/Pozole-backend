#include "AccessControlCtrl.h"

AccessControlCtrl::AccessControlCtrl() {
    std::string datos[10][2] = {
        {"101","4821"},{"102","7365"},{"201","1948"},{"202","8257"},{"301","3619"},
        {"302","5074"},{"401","9183"},{"402","2467"},{"501","6542"},{"502","7831"}
    };
    for (int i = 0; i < 10; ++i) {
        Apartamento a;
        a.apartamento = datos[i][0];
        a.codigos_registrados = datos[i][1];
        apts.push_back(a);
    }
}

void AccessControlCtrl::login(const HttpRequestPtr& req, std::function<void(const HttpResponsePtr&)>&& callback) {
    auto json = req->getJsonObject();
    if (!json) {
        auto resp = HttpResponse::newHttpResponse();
        resp->setStatusCode(k400BadRequest);
        callback(resp);
        return;
    }

    int tipo_usuario = (*json)["tipo_usuario"].asInt(); // 1: Residente, 2: Visitante
    std::string num_apartamento = (*json)["apartamento"].asString();
    std::string codigo_acceso = (*json)["codigo_acceso"].asString(); // Opcional para visitante

    Json::Value resJson;
    bool encontrado = false;

    std::lock_guard<std::mutex> lock(mtx_);

    for (auto& apt : apts) {
        if (apt.apartamento == num_apartamento) {
            encontrado = true;
            if (tipo_usuario == 1) { // Residente
                if (apt.bloqueado) {
                    resJson["status"] = "error";
                    resJson["message"] = "Acceso bloqueado. Contacte a administracion.";
                } else {
                    if (codigo_acceso == apt.codigos_registrados) {
                        apt.intentos_fallidos = 0;
                        resJson["status"] = "success";
                        resJson["message"] = "Acceso permitido. Registro de ingreso realizado.";
                    } else {
                        apt.intentos_fallidos++;
                        if (apt.intentos_fallidos >= 3) {
                            apt.bloqueado = true;
                            resJson["status"] = "error";
                            resJson["message"] = "Codigo incorrecto. Acceso bloqueado.";
                        } else {
                            resJson["status"] = "error";
                            resJson["message"] = "Codigo incorrecto. Intentos fallidos: " + std::to_string(apt.intentos_fallidos) + "/3";
                        }
                    }
                }
            } else if (tipo_usuario == 2) { // Visitante
                if (apt.invitacion) {
                    apt.invitacion = false;
                    resJson["status"] = "success";
                    resJson["message"] = "Acceso permitido. Invitacion utilizada correctamente.";
                } else {
                    resJson["status"] = "error";
                    resJson["message"] = "No existe una invitacion activa. Acceso denegado.";
                }
            } else {
                resJson["status"] = "error";
                resJson["message"] = "Tipo de usuario invalido.";
            }
            break;
        }
    }

    if (!encontrado) {
        resJson["status"] = "error";
        resJson["message"] = "Apartamento no encontrado.";
    }

    auto resp = HttpResponse::newHttpJsonResponse(resJson);
    callback(resp);
}

void AccessControlCtrl::registrarInvitacion(const HttpRequestPtr& req, std::function<void(const HttpResponsePtr&)>&& callback) {
    auto json = req->getJsonObject();
    if (!json) {
        auto resp = HttpResponse::newHttpResponse();
        resp->setStatusCode(k400BadRequest);
        callback(resp);
        return;
    }

    std::string num_apartamento = (*json)["apartamento"].asString();
    
    Json::Value resJson;
    bool encontrado = false;

    std::lock_guard<std::mutex> lock(mtx_);

    for (auto& apt : apts) {
        if (apt.apartamento == num_apartamento) {
            encontrado = true;
            apt.invitacion = true;
            resJson["status"] = "success";
            resJson["message"] = "Invitacion registrada correctamente.";
            break;
        }
    }

    if (!encontrado) {
        resJson["status"] = "error";
        resJson["message"] = "Apartamento no encontrado.";
    }

    auto resp = HttpResponse::newHttpJsonResponse(resJson);
    callback(resp);
}
