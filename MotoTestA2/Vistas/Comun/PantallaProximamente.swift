// PantallaProximamente.swift
// ------------------------------------------------------------------
// Pantalla provisional para las secciones que aún no existen.
// Se irá sustituyendo fase a fase.
// ------------------------------------------------------------------

import SwiftUI

struct PantallaProximamente: View {
    let titulo: String

    var body: some View {
        // ContentUnavailableView: vista estándar de iOS 17 para "vacío"
        ContentUnavailableView(titulo,
                               systemImage: "hammer",
                               description: Text("Disponible en una próxima fase."))
            .navigationTitle(titulo)
    }
}
