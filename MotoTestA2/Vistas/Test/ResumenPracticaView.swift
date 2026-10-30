// ResumenPracticaView.swift
// ------------------------------------------------------------------
// Resultado al terminar una práctica: aciertos, porcentaje y la lista
// de preguntas falladas con la respuesta correcta y su explicación.
// ------------------------------------------------------------------

import SwiftUI

struct ResumenPracticaView: View {
    let vm: TestViewModel
    let alCerrar: () -> Void

    private var porcentaje: Int {
        guard !vm.preguntas.isEmpty else { return 0 }
        return Int((Double(vm.numAciertos) / Double(vm.preguntas.count) * 100).rounded())
    }

    /// Índices de las preguntas falladas
    private var indicesFallados: [Int] {
        vm.preguntas.indices.filter { !vm.esAcierto($0) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Marcador
                VStack(spacing: 6) {
                    Text("\(vm.numAciertos) / \(vm.preguntas.count)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                    Text("\(porcentaje) % de aciertos · \(vm.numFallos) fallos")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                if indicesFallados.isEmpty {
                    Label("¡Sin fallos! 🏍️", systemImage: "star.fill")
                        .font(.title3.bold())
                        .foregroundStyle(.green)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Repasa tus fallos")
                            .font(.headline)

                        ForEach(indicesFallados, id: \.self) { indice in
                            tarjetaFallo(indice)
                        }
                    }
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: alCerrar) {
                Text("Volver al inicio")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
            .background(.bar)
        }
    }

    private func tarjetaFallo(_ indice: Int) -> some View {
        let pregunta = vm.preguntas[indice]
        let letras = ["A", "B", "C"]

        return VStack(alignment: .leading, spacing: 8) {
            Text(pregunta.enunciado)
                .font(.subheadline.weight(.semibold))

            if let elegida = vm.respuestas[indice] {
                Label("Tu respuesta: \(letras[elegida]). \(pregunta.opciones[elegida])",
                      systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.callout)
            }
            Label("Correcta: \(letras[pregunta.correcta]). \(pregunta.opciones[pregunta.correcta])",
                  systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.callout)

            Text(pregunta.explicacion)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 14))
    }
}
