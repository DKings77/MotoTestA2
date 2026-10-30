// GestorFallos.swift
// ------------------------------------------------------------------
// Aplica las reglas de "Mis fallos" cada vez que respondes una pregunta,
// en CUALQUIER modo:
//   - Fallas  → entra en Mis fallos (o suma un fallo y pone a 0 la racha).
//   - Aciertas una que estaba en Mis fallos → racha + 1.
//   - Racha = 2 → sale de Mis fallos.
//
// Se guarda al momento, así que aunque abandones un test a medias,
// lo que ya has fallado queda apuntado.
// La pantalla "Mis fallos" llega en la fase 5, pero los datos ya se
// van acumulando desde ahora.
// ------------------------------------------------------------------

import Foundation
import SwiftData

enum GestorFallos {
    static func registrar(preguntaID: String, acertada: Bool, en contexto: ModelContext) {
        // Buscamos si la pregunta ya está en Mis fallos.
        // "#Predicate" es el filtro (como un WHERE de SQL).
        let id = preguntaID
        let consulta = FetchDescriptor<FalloPendiente>(
            predicate: #Predicate { $0.preguntaID == id }
        )
        let existente = try? contexto.fetch(consulta).first

        if acertada {
            // Solo nos interesa si estaba en Mis fallos
            guard let fallo = existente else { return }
            fallo.aciertosSeguidos += 1
            if fallo.aciertosSeguidos >= ReglasExamen.aciertosParaSalirDeFallos {
                contexto.delete(fallo)   // ¡superada!
            }
        } else {
            if let fallo = existente {
                fallo.vecesFallada += 1
                fallo.aciertosSeguidos = 0
                fallo.ultimaVez = .now
            } else {
                contexto.insert(FalloPendiente(preguntaID: id))
            }
        }
    }
}
