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
    // El banco de preguntas se crea UNA vez al arrancar y se comparte
    // con todas las pantallas mediante ".environment(banco)".
    // "@State" hace que SwiftUI lo conserve mientras la app esté abierta.
    @State private var banco = BancoPreguntas()

    var body: some Scene {
        WindowGroup {
            InicioView()
                .environment(banco)
        }
        .modelContainer(for: [
            Intento.self,
            RespuestaRegistrada.self,
            FalloPendiente.self
        ])
    }
}
