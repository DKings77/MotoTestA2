// Pregunta.swift
// ------------------------------------------------------------------
// Una pregunta del banco, tal cual viene en preguntas.json.
//
// Es un "struct" normal (NO de SwiftData): las preguntas se cargan en
// memoria desde el JSON cada vez que arranca la app. Así, cambiar o
// ampliar el banco no obliga a tocar la base de datos.
//
// Los nombres de las propiedades coinciden EXACTAMENTE con las claves
// del JSON; por eso "Codable" puede leerlo sin código extra.
// ------------------------------------------------------------------

import Foundation

struct Pregunta: Codable, Identifiable, Hashable {
    let id: String
    let tema: Tema
    let enunciado: String
    let opciones: [String]      // siempre 3
    let correcta: Int           // índice de la correcta: 0, 1 o 2
    let explicacion: String
    let imagen: String?         // nombre de imagen, base64 o null

    /// Comprueba que la pregunta está bien formada.
    /// Se usa al cargar el JSON para descartar preguntas rotas
    /// en lugar de que la app falle.
    var esValida: Bool {
        !id.isEmpty
        && !enunciado.isEmpty
        && opciones.count == 3
        && (0..<opciones.count).contains(correcta)
    }
}
