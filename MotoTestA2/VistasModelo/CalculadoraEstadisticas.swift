// CalculadoraEstadisticas.swift
// ------------------------------------------------------------------
// Calcula todas las estadísticas a partir de lo guardado.
// No se guarda ninguna estadística: se recalculan siempre, así nunca
// se desincronizan con el historial.
// ------------------------------------------------------------------

import Foundation

/// Un simulacro en el gráfico de evolución.
struct PuntoSimulacro: Identifiable {
    let numero: Int      // 1 = el más antiguo de los mostrados
    let fallos: Int
    let aprobado: Bool
    var id: Int { numero }
}

/// Aciertos de un tema (sumando todos los modos).
struct EstadisticaTema: Identifiable {
    let tema: Tema
    let respondidas: Int
    let aciertos: Int
    var id: String { tema.rawValue }

    /// De 0 a 1, o nil si aún no has respondido ninguna.
    var porcentaje: Double? {
        respondidas == 0 ? nil : Double(aciertos) / Double(respondidas)
    }
    var datosSuficientes: Bool { respondidas >= ReglasExamen.minimoRespuestasPorTema }
    var superado: Bool { datosSuficientes && (porcentaje ?? 0) >= ReglasExamen.aciertoMinimoPorTema }
}

struct CalculadoraEstadisticas {
    let intentos: [Intento]                 // ordenados del más reciente al más antiguo
    let respuestas: [RespuestaRegistrada]

    // MARK: - Resumen

    var simulacros: [Intento] { intentos.filter { $0.modo == .simulacro } }
    var numTests: Int { intentos.count }
    var numSimulacros: Int { simulacros.count }
    var numAprobados: Int { simulacros.filter { $0.aprobado == true }.count }

    var porcentajeAprobados: Double? {
        numSimulacros == 0 ? nil : Double(numAprobados) / Double(numSimulacros)
    }

    var mediaFallos: Double? {
        guard numSimulacros > 0 else { return nil }
        return Double(simulacros.map(\.numFallos).reduce(0, +)) / Double(numSimulacros)
    }

    /// Últimos 10 simulacros, del más antiguo al más reciente (para el gráfico).
    var ultimos10: [PuntoSimulacro] {
        simulacros.prefix(10).reversed().enumerated().map { indice, intento in
            PuntoSimulacro(numero: indice + 1,
                           fallos: intento.numFallos,
                           aprobado: intento.aprobado ?? false)
        }
    }

    // MARK: - Por tema

    var porTema: [EstadisticaTema] {
        Tema.allCases.map { tema in
            let delTema = respuestas.filter { $0.temaRaw == tema.rawValue }
            return EstadisticaTema(tema: tema,
                                   respondidas: delTema.count,
                                   aciertos: delTema.filter(\.acertada).count)
        }
    }

    // MARK: - ¿Estoy listo?

    /// Aprobados entre los 5 últimos simulacros.
    var aprobadosUltimos5: Int {
        simulacros.prefix(ReglasExamen.simulacrosParaEstarListo).filter { $0.aprobado == true }.count
    }

    var cumpleSimulacros: Bool {
        aprobadosUltimos5 == ReglasExamen.simulacrosParaEstarListo
    }

    var temasSuperados: Int { porTema.filter(\.superado).count }
    var cumpleTemas: Bool { temasSuperados == Tema.allCases.count }

    var estaListo: Bool { cumpleSimulacros && cumpleTemas }
}
