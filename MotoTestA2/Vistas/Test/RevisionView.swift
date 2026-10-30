// RevisionView.swift
// ------------------------------------------------------------------
// Revisión pregunta a pregunta: tu respuesta, la correcta y la
// explicación. Se usa tras el simulacro y, en la fase 6, desde el
// historial de estadísticas.
// ------------------------------------------------------------------

import SwiftUI

/// Una pregunta tal como se respondió en un test.
struct ItemRevision: Identifiable {
    let id = UUID()
    let numero: Int          // posición en el test (1…20)
    let pregunta: Pregunta
    let elegida: Int?        // nil = en blanco

    var acierto: Bool { elegida == pregunta.correcta }
}

struct RevisionView: View {
    let items: [ItemRevision]
    @State private var soloFallos = false

    private var visibles: [ItemRevision] {
        soloFallos ? items.filter { !$0.acierto } : items
    }

    var body: some View {
        List {
            Section {
                Picker("Mostrar", selection: $soloFallos) {
                    Text("Todas (\(items.count))").tag(false)
                    Text("Fallos (\(items.filter { !$0.acierto }.count))").tag(true)
                }
                .pickerStyle(.segmented)
            }

            ForEach(visibles) { item in
                Section {
                    filaRevision(item)
                }
            }
        }
        .navigationTitle("Revisión")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func filaRevision(_ item: ItemRevision) -> some View {
        let p = item.pregunta

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Pregunta \(item.numero)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                if item.elegida == nil {
                    Label("En blanco", systemImage: "circle.dashed")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: item.acierto ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(item.acierto ? Color.green : Color.red)
                }
            }

            if let imagen = p.imagen {
                ImagenPregunta(referencia: imagen)
                    .frame(maxWidth: .infinity, maxHeight: 120)
            }

            Text(p.enunciado)
                .font(.subheadline.weight(.semibold))

            // Las 3 opciones con su marca
            ForEach(Array(p.opciones.enumerated()), id: \.offset) { indice, texto in
                let esCorrecta = indice == p.correcta
                let esElegida = indice == item.elegida
                HStack(alignment: .top, spacing: 8) {
                    Text(Formato.letras[indice]).bold()
                    Text(texto)
                    Spacer(minLength: 4)
                    if esCorrecta {
                        Image(systemName: "checkmark").foregroundStyle(.green)
                    } else if esElegida {
                        Image(systemName: "xmark").foregroundStyle(.red)
                    }
                }
                .font(.callout)
                .foregroundStyle(esCorrecta ? Color.green : (esElegida ? Color.red : Color.primary))
            }

            Text(p.explicacion)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
