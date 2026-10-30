// SeleccionTemasView.swift
// ------------------------------------------------------------------
// Elegir uno o varios temas y cuántas preguntas, y empezar.
// Funciona igual que la práctica (corrección al momento).
// ------------------------------------------------------------------

import SwiftUI

struct SeleccionTemasView: View {
    @Environment(BancoPreguntas.self) private var banco

    @State private var seleccion: Set<Tema> = []   // temas marcados
    @State private var cantidad = 20               // 0 = todas
    @State private var testActivo: ConfigTest?     // cuando tiene valor, se abre el test

    /// Preguntas disponibles con los temas marcados
    private var disponibles: Int { banco.preguntas(de: seleccion).count }

    /// Preguntas que tendrá el test realmente
    private var numFinal: Int {
        cantidad == 0 ? disponibles : min(cantidad, disponibles)
    }

    var body: some View {
        List {
            Section {
                ForEach(Tema.allCases) { tema in
                    Button {
                        alternar(tema)
                    } label: {
                        filaTema(tema)
                    }
                }
            } header: {
                Text("Temas")
            } footer: {
                Text("Toca para marcar o desmarcar. El número indica cuántas preguntas hay de cada tema.")
            }

            Section("Número de preguntas") {
                Picker("Preguntas", selection: $cantidad) {
                    Text("10").tag(10)
                    Text("20").tag(20)
                    Text("30").tag(30)
                    Text("Todas").tag(0)
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Por temas")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(seleccion.count == Tema.allCases.count ? "Ninguno" : "Todos") {
                    if seleccion.count == Tema.allCases.count {
                        seleccion.removeAll()
                    } else {
                        seleccion = Set(Tema.allCases)
                    }
                }
            }
        }
        // Botón fijo abajo, al alcance del pulgar
        .safeAreaInset(edge: .bottom) {
            Button {
                empezar()
            } label: {
                Text(disponibles == 0 ? "Elige al menos un tema" : "Empezar · \(numFinal) preguntas")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(disponibles == 0)
            .padding()
            .background(.bar)
        }
        .fullScreenCover(item: $testActivo) { config in
            TestView(config: config)
        }
    }

    private func filaTema(_ tema: Tema) -> some View {
        let marcado = seleccion.contains(tema)
        return HStack(spacing: 12) {
            Image(systemName: tema.icono)
                .frame(width: 28)
                .foregroundStyle(.tint)
            Text(tema.nombre)
                .foregroundStyle(.primary)
            Spacer()
            Text("\(banco.cuantas(de: tema))")
                .foregroundStyle(.secondary)
            Image(systemName: marcado ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(marcado ? Color.accentColor : Color.secondary)
        }
        .contentShape(Rectangle())
    }

    private func alternar(_ tema: Tema) {
        if seleccion.contains(tema) {
            seleccion.remove(tema)
        } else {
            seleccion.insert(tema)
        }
    }

    private func empezar() {
        let preguntas = GeneradorTests.aleatorias(de: banco.preguntas(de: seleccion),
                                                  cantidad: cantidad)
        guard !preguntas.isEmpty else { return }
        testActivo = ConfigTest(modo: .temas, preguntas: preguntas)
    }
}
