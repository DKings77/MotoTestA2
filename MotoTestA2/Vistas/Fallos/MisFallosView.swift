// MisFallosView.swift
// ------------------------------------------------------------------
// Preguntas falladas pendientes de repaso.
//   - Cada pregunta muestra cuántas veces la has fallado y su racha
//     de aciertos (●○ = 1 de 2). Con 2 aciertos seguidos sale sola.
//   - "Repasar" abre un test con las más falladas (máx. 20).
//   - Desliza a la izquierda para quitar una manualmente.
// ------------------------------------------------------------------

import SwiftUI
import SwiftData

/// Un fallo junto con su pregunta del banco.
private struct FalloConPregunta: Identifiable {
    let fallo: FalloPendiente
    let pregunta: Pregunta
    var id: String { pregunta.id }
}

struct MisFallosView: View {
    @Environment(BancoPreguntas.self) private var banco
    @Environment(\.modelContext) private var contexto
    @Query(sort: \FalloPendiente.ultimaVez, order: .reverse) private var fallos: [FalloPendiente]
    @State private var testActivo: ConfigTest?

    /// Fallos cuya pregunta existe en el banco actual.
    private var pendientes: [FalloConPregunta] {
        fallos.compactMap { fallo in
            banco.pregunta(id: fallo.preguntaID).map { FalloConPregunta(fallo: fallo, pregunta: $0) }
        }
    }

    /// Fallos de preguntas que ya no están en el banco (p. ej. tras cambiar de banco).
    private var huerfanos: [FalloPendiente] {
        fallos.filter { banco.pregunta(id: $0.preguntaID) == nil }
    }

    private var numRepaso: Int { min(pendientes.count, ReglasExamen.numPreguntas) }

    var body: some View {
        Group {
            if pendientes.isEmpty && huerfanos.isEmpty {
                ContentUnavailableView("Sin fallos pendientes",
                                       systemImage: "checkmark.seal",
                                       description: Text("Las preguntas que falles en cualquier modo aparecerán aquí. Salen al acertarlas 2 veces seguidas."))
            } else {
                lista
            }
        }
        .navigationTitle("Mis fallos")
        .fullScreenCover(item: $testActivo) { config in
            TestView(config: config)
        }
    }

    private var lista: some View {
        List {
            Section {
                ForEach(pendientes) { item in
                    NavigationLink {
                        DetallePreguntaView(pregunta: item.pregunta)
                    } label: {
                        fila(item)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            contexto.delete(item.fallo)
                        } label: {
                            Label("Quitar", systemImage: "trash")
                        }
                    }
                }
            } header: {
                Text("\(pendientes.count) preguntas pendientes")
            } footer: {
                Text("● = acierto seguido. Con 2 aciertos seguidos la pregunta sale del repaso; si la vuelves a fallar, la racha vuelve a cero.")
            }

            if !huerfanos.isEmpty {
                Section {
                    Button("Limpiar \(huerfanos.count) fallos de preguntas que ya no existen", role: .destructive) {
                        huerfanos.forEach { contexto.delete($0) }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if numRepaso > 0 {
                Button {
                    empezarRepaso()
                } label: {
                    Text("Repasar \(numRepaso) \(numRepaso == 1 ? "pregunta" : "preguntas")")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
                .background(.bar)
            }
        }
    }

    private func fila(_ item: FalloConPregunta) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.pregunta.enunciado)
                .font(.subheadline)
                .lineLimit(3)
            HStack(spacing: 8) {
                Label(item.pregunta.tema.nombre, systemImage: item.pregunta.tema.icono)
                    .lineLimit(1)
                Spacer()
                Text("✕ \(item.fallo.vecesFallada)")
                    .foregroundStyle(.red)
                // Racha: un círculo por cada acierto necesario
                HStack(spacing: 2) {
                    ForEach(0..<ReglasExamen.aciertosParaSalirDeFallos, id: \.self) { i in
                        Image(systemName: i < item.fallo.aciertosSeguidos ? "circle.fill" : "circle")
                    }
                }
                .foregroundStyle(.green)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    /// Repaso con las más falladas primero (máximo 20), en orden aleatorio.
    private func empezarRepaso() {
        let elegidas = pendientes
            .sorted { $0.fallo.vecesFallada > $1.fallo.vecesFallada }
            .prefix(ReglasExamen.numPreguntas)
            .map(\.pregunta)
            .shuffled()
        guard !elegidas.isEmpty else { return }
        testActivo = ConfigTest(modo: .fallos, preguntas: elegidas)
    }
}
