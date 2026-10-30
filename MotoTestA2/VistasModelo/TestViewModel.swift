// TestViewModel.swift
// ------------------------------------------------------------------
// El "cerebro" de un test (patrón MVVM: la Vista dibuja, el
// ViewModel decide). Guarda qué pregunta toca, qué has respondido
// y calcula el resultado. La vista solo lee de aquí y llama a
// responder() / siguiente().
//
// En esta fase lo usan Práctica y Por temas. En la fase 4 se ampliará
// para el simulacro (cronómetro, sin corrección hasta el final).
// ------------------------------------------------------------------

import Foundation
import SwiftData
import Observation

@Observable
final class TestViewModel {
    let modo: ModoTest
    let preguntas: [Pregunta]
    let inicio = Date()

    /// Posición de la pregunta que se está mostrando (0, 1, 2…)
    private(set) var indiceActual = 0
    /// Respuesta elegida para cada pregunta (nil = sin responder)
    private(set) var respuestas: [Int?]
    /// true cuando ya se han hecho todas las preguntas
    private(set) var terminado = false

    init(modo: ModoTest, preguntas: [Pregunta]) {
        self.modo = modo
        self.preguntas = preguntas
        self.respuestas = Array(repeating: nil, count: preguntas.count)
    }

    // MARK: - Datos para la vista

    var preguntaActual: Pregunta { preguntas[indiceActual] }
    var respuestaActual: Int? { respuestas[indiceActual] }
    var yaRespondida: Bool { respuestaActual != nil }
    var esUltima: Bool { indiceActual == preguntas.count - 1 }

    /// Progreso de 0 a 1 para la barra superior
    var progreso: Double {
        guard !preguntas.isEmpty else { return 0 }
        return Double(respuestas.compactMap { $0 }.count) / Double(preguntas.count)
    }

    /// Una pregunta sin responder cuenta como fallo.
    func esAcierto(_ indice: Int) -> Bool {
        respuestas[indice] == preguntas[indice].correcta
    }

    var numAciertos: Int { preguntas.indices.filter { esAcierto($0) }.count }
    var numFallos: Int { preguntas.count - numAciertos }

    // MARK: - Acciones

    /// Registra la respuesta. Devuelve true si es correcta, false si no,
    /// o nil si la pregunta ya estaba respondida (no se puede cambiar).
    @discardableResult
    func responder(_ opcion: Int, contexto: ModelContext) -> Bool? {
        guard !yaRespondida else { return nil }
        respuestas[indiceActual] = opcion
        let acierto = opcion == preguntaActual.correcta
        GestorFallos.registrar(preguntaID: preguntaActual.id, acertada: acierto, en: contexto)
        return acierto
    }

    /// Pasa a la siguiente pregunta o termina el test.
    func siguiente() {
        if esUltima {
            terminado = true
        } else {
            indiceActual += 1
        }
    }

    /// Guarda el test terminado en SwiftData (para las estadísticas).
    func guardar(en contexto: ModelContext) {
        let intento = Intento(modo: modo,
                              duracionSegundos: Int(Date().timeIntervalSince(inicio)),
                              numPreguntas: preguntas.count,
                              numFallos: numFallos,
                              aprobado: nil)   // solo los simulacros son APTO / NO APTO
        contexto.insert(intento)

        for (indice, pregunta) in preguntas.enumerated() {
            let respuesta = RespuestaRegistrada(preguntaID: pregunta.id,
                                                tema: pregunta.tema,
                                                elegida: respuestas[indice],
                                                acertada: esAcierto(indice),
                                                orden: indice)
            intento.respuestas.append(respuesta)   // queda enlazada al intento
        }
    }
}
