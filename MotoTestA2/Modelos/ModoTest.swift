// ModoTest.swift
// ------------------------------------------------------------------
// Los modos en que se puede hacer un test, y las reglas del examen.
// ------------------------------------------------------------------

import Foundation

enum ModoTest: String, Codable, CaseIterable {
    case simulacro   // 20 preguntas, 20 min, sin ver solución hasta el final
    case practica    // feedback inmediato, sin tiempo
    case temas       // como práctica, filtrado por temas
    case fallos      // repaso de preguntas falladas

    var nombre: String {
        switch self {
        case .simulacro: return "Simulacro"
        case .practica:  return "Práctica"
        case .temas:     return "Por temas"
        case .fallos:    return "Repaso de fallos"
        }
    }

    /// Solo el simulacro oculta la solución hasta el final.
    var muestraSolucionAlMomento: Bool { self != .simulacro }
}

/// Reglas del examen real de la DGT, en un único sitio.
/// Si algún día cambian, solo hay que tocar aquí.
enum ReglasExamen {
    static let numPreguntas = 20
    static let maxFallos = 2                  // 3 fallos = NO APTO
    static let duracionSegundos = 20 * 60     // 20 minutos
    static let aciertosParaSalirDeFallos = 2  // aciertos seguidos para sacar una pregunta del repaso
    static let simulacrosParaEstarListo = 5   // indicador "¿Estoy listo?"
    static let aciertoMinimoPorTema = 0.85    // 85 % en cada tema
    static let minimoRespuestasPorTema = 10   // respuestas mínimas para fiarse del % de un tema
}
