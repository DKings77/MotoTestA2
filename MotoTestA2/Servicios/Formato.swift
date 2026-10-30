// Formato.swift
// ------------------------------------------------------------------
// Pequeñas utilidades para mostrar datos.
// ------------------------------------------------------------------

import Foundation

enum Formato {
    /// 754 segundos → "12:34"
    static func minutosSegundos(_ segundos: Int) -> String {
        let s = max(0, segundos)
        return String(format: "%02d:%02d", s / 60, s % 60)
    }

    /// Letra de cada opción
    static let letras = ["A", "B", "C"]
}
