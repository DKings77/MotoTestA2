// RespuestaRegistrada.swift
// ------------------------------------------------------------------
// Una respuesta concreta dentro de un intento.
//
// Guardamos el id de la pregunta (no la pregunta entera): la pregunta
// se busca en el banco cargado del JSON cuando haga falta.
// Copiamos también el tema para que las estadísticas por tema sigan
// funcionando aunque la pregunta desaparezca de un banco futuro.
// ------------------------------------------------------------------

import Foundation
import SwiftData

@Model
final class RespuestaRegistrada {
    var preguntaID: String
    var temaRaw: String
    var elegida: Int?        // nil = la dejaste sin responder (cuenta como fallo)
    var acertada: Bool
    var orden: Int           // posición de la pregunta en el test (0, 1, 2…)
    var intento: Intento?    // a qué intento pertenece

    var tema: Tema? { Tema(rawValue: temaRaw) }

    init(preguntaID: String, tema: Tema, elegida: Int?, acertada: Bool, orden: Int) {
        self.preguntaID = preguntaID
        self.temaRaw = tema.rawValue
        self.elegida = elegida
        self.acertada = acertada
        self.orden = orden
    }
}
