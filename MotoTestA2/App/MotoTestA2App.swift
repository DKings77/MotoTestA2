// MotoTestA2App.swift
// ------------------------------------------------------------------
// Punto de entrada de la app: iOS arranca aquí.
//
// - "@main" marca la estructura que arranca la aplicación.
// - "WindowGroup" es la ventana principal; dentro va la primera pantalla.
// - ".modelContainer(for:)" crea la base de datos local de SwiftData
//   (un fichero SQLite dentro de la app) con las tablas que le pasamos.
//   Todas las vistas que cuelgan de aquí pueden leer y guardar datos.
//
// Solo guardamos el PROGRESO (intentos, respuestas, fallos).
// Las preguntas viven en el JSON, no en la base de datos.
// ------------------------------------------------------------------

import SwiftUI
import SwiftData

@main
struct MotoTestA2App: App {
    var body: some Scene {
        WindowGroup {
            InicioView()
        }
        .modelContainer(for: [
            Intento.self,
            RespuestaRegistrada.self,
            FalloPendiente.self
        ])
    }
}
