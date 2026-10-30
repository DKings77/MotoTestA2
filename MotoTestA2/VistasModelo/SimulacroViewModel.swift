// SimulacroViewModel.swift
// ------------------------------------------------------------------
// Lógica del simulacro de examen. Diferencias con la práctica:
//   - Hay un límite de 20 minutos.
//   - No se ve si aciertas hasta corregir.
//   - Puedes cambiar respuestas y saltar entre preguntas.
//   - Al corregir: APTO si fallas 2 como máximo (sin responder = fallo).
//
// El tiempo se calcula con la hora de inicio y no con un contador:
// así, aunque la app pase a segundo plano, el tiempo sigue corriendo
// como en el examen real.
// ------------------------------------------------------------------

import Foundation
import SwiftData
import Observation

@Observable
final class SimulacroViewModel {
    let preguntas: [Pregunta]
    let inicio = Date()
    let fechaLimite: Date

    private(set) var indiceActual = 0
    private(set) var respuestas: [Int?]
    private(set) var corregido = false
    private(set) var segundosUsados = 0
    private(set) var acabadoPorTiempo = false

    init(preguntas: [Pregunta]) {
        self.preguntas = preguntas
        self.respuestas = Array(repeating: nil, count: preguntas.count)
        self.fechaLimite = inicio.addingTimeInterval(TimeInterval(ReglasExamen.duracionSegundos))
    }

    // MARK: - Datos para la vista

    var preguntaActual: Pregunta { preguntas[indiceActual] }
    var respuestaActual: Int? { respuestas[indiceActual] }
    var esPrimera: Bool { indiceActual == 0 }
    var esUltima: Bool { indiceActual == preguntas.count - 1 }

    var numRespondidas: Int { respuestas.compactMap { $0 }.count }
    var sinResponder: Int { preguntas.count - numRespondidas }

    /// Segundos que quedan en un momento dado (nunca negativo).
    func segundosRestantes(en fecha: Date = .now) -> Int {
        max(0, Int(fechaLimite.timeIntervalSince(fecha).rounded(.up)))
    }

    func esAcierto(_ indice: Int) -> Bool {
        respuestas[indice] == preguntas[indice].correcta
    }

    var numAciertos: Int { preguntas.indices.filter { esAcierto($0) }.count }
    var numFallos: Int { preguntas.count - numAciertos }
    var aprobado: Bool { numFallos <= ReglasExamen.maxFallos }

    /// Datos para la pantalla de revisión
    var itemsRevision: [ItemRevision] {
        preguntas.indices.map {
            ItemRevision(numero: $0 + 1, pregunta: preguntas[$0], elegida: respuestas[$0])
        }
    }

    // MARK: - Acciones

    /// Marca (o cambia) la respuesta de la pregunta actual.
    func seleccionar(_ opcion: Int) {
        guard !corregido else { return }
        respuestas[indiceActual] = opcion
    }

    func irA(_ indice: Int) {
        guard preguntas.indices.contains(indice) else { return }
        indiceActual = indice
    }

    func anterior() { irA(indiceActual - 1) }
    func siguiente() { irA(indiceActual + 1) }

    /// Corrige el examen, lo guarda y actualiza "Mis fallos".
    func corregir(contexto: ModelContext, porTiempo: Bool = false) {
        guard !corregido else { return }   // nunca dos veces
        corregido = true
        acabadoPorTiempo = porTiempo
        segundosUsados = min(ReglasExamen.duracionSegundos, Int(Date().timeIntervalSince(inicio)))

        let intento = Intento(modo: .simulacro,
                              duracionSegundos: segundosUsados,
                              numPreguntas: preguntas.count,
                              numFallos: numFallos,
                              aprobado: aprobado)
        contexto.insert(intento)

        for (indice, pregunta) in preguntas.enumerated() {
            let acierto = esAcierto(indice)
            intento.respuestas.append(
                RespuestaRegistrada(preguntaID: pregunta.id,
                                    tema: pregunta.tema,
                                    elegida: respuestas[indice],
                                    acertada: acierto,
                                    orden: indice)
            )
            GestorFallos.registrar(preguntaID: pregunta.id, acertada: acierto, en: contexto)
        }
    }
}
