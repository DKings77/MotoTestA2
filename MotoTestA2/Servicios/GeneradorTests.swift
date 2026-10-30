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
}
