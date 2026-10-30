// GeneradorTests.swift
// ------------------------------------------------------------------
// Elige qué preguntas entran en cada test.
// "enum" sin casos = un simple contenedor de funciones (como una clase
// estática en C# o un módulo en PowerShell).
// ------------------------------------------------------------------

import Foundation

/// Lo necesario para abrir un test: el modo y sus preguntas.
/// "Identifiable" permite usarlo con .fullScreenCover(item:).
struct ConfigTest: Identifiable {
    let id = UUID()
    let modo: ModoTest
    let preguntas: [Pregunta]
}

enum GeneradorTests {
    /// Devuelve "cantidad" preguntas al azar (o todas si cantidad <= 0
    /// o no hay suficientes).
    static func aleatorias(de preguntas: [Pregunta], cantidad: Int) -> [Pregunta] {
        let barajadas = preguntas.shuffled()
        guard cantidad > 0 else { return barajadas }
        return Array(barajadas.prefix(cantidad))
    }

    /// Preguntas para un simulacro: reparte las 20 entre TODOS los temas
    /// (como el examen real), cogiendo una de cada tema por turnos.
    static func simulacro(de preguntas: [Pregunta],
                          cantidad: Int = ReglasExamen.numPreguntas) -> [Pregunta] {
        // Agrupamos por tema y barajamos cada grupo
        var porTema = Dictionary(grouping: preguntas, by: \.tema).mapValues { $0.shuffled() }
        var temas = Tema.allCases.shuffled().filter { porTema[$0] != nil }
        var resultado: [Pregunta] = []

        // Ronda tras ronda: una pregunta de cada tema hasta llegar a 20
        while resultado.count < cantidad && !temas.isEmpty {
            for tema in temas where resultado.count < cantidad {
                if let pregunta = porTema[tema]?.popLast() {   // saca una del tema
                    resultado.append(pregunta)
                }
            }
            // Quitamos los temas que ya se han quedado sin preguntas
            temas = temas.filter { !(porTema[$0]?.isEmpty ?? true) }
        }
        return resultado.shuffled()
    }
}
