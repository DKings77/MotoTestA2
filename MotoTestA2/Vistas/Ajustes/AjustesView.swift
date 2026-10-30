// AjustesView.swift
// ------------------------------------------------------------------
// Ajustes. En la fase 1 solo sirve para COMPROBAR que SwiftData
// guarda datos: añade intentos de prueba y verás cómo el contador
// del inicio sube y se mantiene al cerrar y abrir la app.
// En la fase 7 aquí irá la importación del JSON.
//
// - "@Environment(\.modelContext)" da acceso a la base de datos para
//   insertar y borrar (con @Query solo se lee).
// - SwiftData guarda solo los cambios (autosave); no hace falta "save()".
// ------------------------------------------------------------------

import SwiftUI
import SwiftData

struct AjustesView: View {
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Intento.fecha, order: .reverse) private var intentos: [Intento]
    @Environment(BancoPreguntas.self) private var banco

    var body: some View {
        List {
            // --- Banco de preguntas (fase 2) ---
            Section("Banco de preguntas") {
                LabeledContent("Origen", value: banco.origen)
                LabeledContent("Preguntas válidas", value: "\(banco.preguntas.count)")
                NavigationLink("Ver todas las preguntas") {
                    BancoPreguntasView()
                }
            }

            // Solo aparece si algo del JSON se ha descartado
            if !banco.avisos.isEmpty {
                Section("Avisos al cargar (\(banco.avisos.count))") {
                    ForEach(banco.avisos, id: \.self) { aviso in
                        Label(aviso, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                }
            }

            Section {
                Button("Borrar todos los tests guardados", role: .destructive) {
                    borrarTodo()
                }
            } header: {
                Text("Datos")
            } footer: {
                Text("Útil para quitar los intentos de prueba de la fase 1. No afecta a «Mis fallos».")
            }

            Section("Intentos guardados: \(intentos.count)") {
                ForEach(intentos) { intento in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(intento.modo.nombre).font(.headline)
                            Spacer()
                            if let aprobado = intento.aprobado {
                                Text(aprobado ? "APTO" : "NO APTO")
                                    .font(.caption.bold())
                                    .foregroundStyle(aprobado ? Color.green : Color.red)
                            }
                        }
                        Text("\(intento.numFallos) fallos de \(intento.numPreguntas) · \(intento.fecha.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Ajustes")
    }

    /// Borra todos los intentos (y en cascada sus respuestas).
    private func borrarTodo() {
        for intento in intentos {
            contexto.delete(intento)
        }
    }
}
