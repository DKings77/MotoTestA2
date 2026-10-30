// MotoTestA2App.swift
// ------------------------------------------------------------------
// Punto de entrada de la app. Es el equivalente al "Main" de un
// programa: iOS arranca aquí.
//
// - "@main" le dice al sistema: "esta es la estructura que arranca la app".
// - "App" es el protocolo de SwiftUI para describir una aplicación.
// - "body" devuelve las escenas (ventanas). En iPhone solo hay una:
//   un WindowGroup con la vista inicial.
//
// FASE 0: solo mostramos una pantalla de bienvenida para comprobar
// que toda la cadena (GitHub Actions → Sideloadly → iPhone) funciona.
// En la fase 1 aquí configuraremos SwiftData.
// ------------------------------------------------------------------

import SwiftUI

@main
struct MotoTestA2App: App {
    var body: some Scene {
        WindowGroup {
            PantallaBienvenida()
        }
    }
}

// Vista provisional de la fase 0. Se sustituirá por InicioView.
struct PantallaBienvenida: View {
    var body: some View {
        // VStack apila elementos en vertical, con 16 puntos de separación.
        VStack(spacing: 16) {
            // SF Symbol: iconos del sistema, gratis y vectoriales.
            Image(systemName: "steeringwheel")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("MotoTest A2")
                .font(.largeTitle.bold())

            Text("Fase 0: si ves esto en tu iPhone, la cadena de compilación funciona. 🏍️")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(32)
    }
}

// Vista previa para Xcode (aquí no la usamos, pero no molesta).
#Preview {
    PantallaBienvenida()
}
