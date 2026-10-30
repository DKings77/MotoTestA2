// Rutas.swift
// ------------------------------------------------------------------
// Lista de pantallas a las que se puede navegar desde el inicio.
//
// En SwiftUI moderno la navegación funciona así:
//   1. Un botón "NavigationLink(value: Ruta.practica)" dice A DÓNDE ir.
//   2. El NavigationStack tiene un ".navigationDestination(for: Ruta.self)"
//      que dice QUÉ pantalla mostrar para cada ruta.
// Tenerlo en un enum evita errores de escritura y lo centraliza todo.
//
// "Hashable" es un requisito técnico de NavigationLink(value:).
// ------------------------------------------------------------------

import Foundation

enum Ruta: Hashable {
    case simulacro
    case practica
    case temas
    case fallos
    case estadisticas
    case ajustes

    /// Título que se mostrará en la barra de navegación.
    var titulo: String {
        switch self {
        case .simulacro:    return "Simulacro"
        case .practica:     return "Práctica"
        case .temas:        return "Por temas"
        case .fallos:       return "Mis fallos"
        case .estadisticas: return "Estadísticas"
        case .ajustes:      return "Ajustes"
        }
    }
}
