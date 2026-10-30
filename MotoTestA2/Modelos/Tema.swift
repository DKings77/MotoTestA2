// Tema.swift
// ------------------------------------------------------------------
// Los 8 temas del examen.
//
// Un "enum" es una lista cerrada de valores posibles: así es imposible
// escribir mal un tema en el código.
//
// - "String" detrás del nombre: cada caso tiene un texto asociado
//   (rawValue). Es el que aparece en el JSON, p. ej. "senalizacion".
// - "Codable": Swift sabe leerlo/escribirlo en JSON automáticamente.
// - "CaseIterable": podemos recorrer todos los temas (Tema.allCases),
//   útil para la pantalla "Por temas" y las estadísticas.
// - "Identifiable": requisito para usarlo en listas de SwiftUI.
// ------------------------------------------------------------------

import Foundation

enum Tema: String, Codable, CaseIterable, Identifiable {
    case normas
    case senalizacion
    case seguridad
    case tecnicas
    case pasajeroCarga = "pasajero_carga"   // en el JSON se escribe "pasajero_carga"
    case mecanica
    case documentacion
    case riesgos

    var id: String { rawValue }

    /// Nombre legible para mostrar en pantalla.
    var nombre: String {
        switch self {
        case .normas:        return "Normas de circulación"
        case .senalizacion:  return "Señalización"
        case .seguridad:     return "Seguridad y equipamiento"
        case .tecnicas:      return "Técnicas de conducción"
        case .pasajeroCarga: return "Pasajero y carga"
        case .mecanica:      return "Mecánica y mantenimiento"
        case .documentacion: return "Documentación y permisos"
        case .riesgos:       return "Factores de riesgo"
        }
    }

    /// Icono del sistema (SF Symbols) para cada tema.
    var icono: String {
        switch self {
        case .normas:        return "list.bullet.rectangle"
        case .senalizacion:  return "exclamationmark.triangle"
        case .seguridad:     return "shield.lefthalf.filled"
        case .tecnicas:      return "arrow.triangle.turn.up.right.diamond"
        case .pasajeroCarga: return "person.2"
        case .mecanica:      return "wrench.and.screwdriver"
        case .documentacion: return "doc.text"
        case .riesgos:       return "exclamationmark.octagon"
        }
    }
}
