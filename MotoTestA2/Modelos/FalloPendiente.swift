// FalloPendiente.swift
// ------------------------------------------------------------------
// Una pregunta que está en "Mis fallos".
//
// Reglas (se aplicarán en la fase 5):
//   - Fallas una pregunta en cualquier modo → entra aquí (o suma vecesFallada).
//   - Aciertas una pregunta que está aquí → aciertosSeguidos + 1.
//   - La vuelves a fallar → aciertosSeguidos vuelve a 0.
//   - Llega a 2 aciertos seguidos → sale del repaso.
//
// "@Attribute(.unique)": no puede haber dos filas con el mismo
// preguntaID. Si se inserta otra igual, SwiftData actualiza la existente.
// ------------------------------------------------------------------

import Foundation
import SwiftData

@Model
final class FalloPendiente {
    @Attribute(.unique) var preguntaID: String
    var aciertosSeguidos: Int
    var vecesFallada: Int
    var ultimaVez: Date

    init(preguntaID: String) {
        self.preguntaID = preguntaID
        self.aciertosSeguidos = 0
        self.vecesFallada = 1
        self.ultimaVez = .now
    }
}
