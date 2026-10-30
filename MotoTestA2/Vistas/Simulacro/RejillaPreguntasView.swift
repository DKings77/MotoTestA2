// RejillaPreguntasView.swift
// ------------------------------------------------------------------
// Hoja con los números 1–20 para saltar a cualquier pregunta.
// En naranja: respondidas. Con borde: la pregunta actual.
// ------------------------------------------------------------------

import SwiftUI

struct RejillaPreguntasView: View {
    let vm: SimulacroViewModel
    let alElegir: () -> Void

    // 5 columnas del mismo ancho
    private let columnas = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columnas, spacing: 12) {
                    ForEach(vm.preguntas.indices, id: \.self) { indice in
                        Button {
                            vm.irA(indice)
                            alElegir()
                        } label: {
                            casilla(indice)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()

                Text("En color, las preguntas respondidas · \(vm.sinResponder) sin responder")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .navigationTitle("Ir a la pregunta")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func casilla(_ indice: Int) -> some View {
        let respondida = vm.respuestas[indice] != nil
        let actual = indice == vm.indiceActual

        return Text("\(indice + 1)")
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(respondida ? Color.accentColor : Color(.tertiarySystemFill),
                        in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(respondida ? Color.white : Color.primary)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(actual ? Color.primary : Color.clear, lineWidth: 3)
            )
    }
}
