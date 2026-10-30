// SimulacroView.swift
// ------------------------------------------------------------------
// Pantalla del simulacro de examen (a pantalla completa).
//
// Barra superior: ✕ (abandonar) · cronómetro · Corregir
// Debajo: "Pregunta X de 20" y un botón con la rejilla para saltar.
// Abajo (pulgar): las 3 respuestas y los botones Anterior / Siguiente.
// ------------------------------------------------------------------

import SwiftUI
import SwiftData

struct SimulacroView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var contexto

    @State private var vm: SimulacroViewModel
    @State private var pidiendoSalir = false
    @State private var pidiendoCorregir = false
    @State private var mostrandoRejilla = false

    init(preguntas: [Pregunta]) {
        _vm = State(initialValue: SimulacroViewModel(preguntas: preguntas))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.corregido {
                    ResultadoSimulacroView(vm: vm) { dismiss() }
                } else {
                    examen
                }
            }
            .navigationTitle(vm.corregido ? "Resultado" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !vm.corregido {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            pidiendoSalir = true
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        CronometroView(vm: vm)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Corregir") { pidiendoCorregir = true }
                            .bold()
                    }
                }
            }
            .confirmationDialog("¿Abandonar el simulacro?",
                                isPresented: $pidiendoSalir,
                                titleVisibility: .visible) {
                Button("Abandonar", role: .destructive) { dismiss() }
                Button("Seguir", role: .cancel) { }
            } message: {
                Text("No se guardará nada de este simulacro.")
            }
            .alert("¿Corregir el examen?", isPresented: $pidiendoCorregir) {
                Button("Corregir") { vm.corregir(contexto: contexto) }
                Button("Seguir respondiendo", role: .cancel) { }
            } message: {
                if vm.sinResponder > 0 {
                    Text("Te quedan \(vm.sinResponder) preguntas sin responder. Contarán como fallos.")
                } else {
                    Text("Has respondido todas las preguntas.")
                }
            }
            .sheet(isPresented: $mostrandoRejilla) {
                RejillaPreguntasView(vm: vm) { mostrandoRejilla = false }
                    .presentationDetents([.medium])
            }
            // Vigila el tiempo mientras la pantalla está abierta
            .task {
                await vigilarTiempo()
            }
        }
    }

    // MARK: - Examen en curso

    private var examen: some View {
        let pregunta = vm.preguntaActual

        return VStack(spacing: 0) {
            // Cabecera: número de pregunta y acceso a la rejilla
            Button {
                mostrandoRejilla = true
            } label: {
                HStack {
                    Text("Pregunta \(vm.indiceActual + 1) de \(vm.preguntas.count)")
                        .font(.headline)
                    Spacer()
                    Label("\(vm.numRespondidas)/\(vm.preguntas.count)", systemImage: "square.grid.3x3")
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()

            // Enunciado e imagen
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let imagen = pregunta.imagen {
                        ImagenPregunta(referencia: imagen)
                            .frame(maxWidth: .infinity)
                    }
                    Text(pregunta.enunciado)
                        .font(.title3.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Respuestas y navegación
            VStack(spacing: 10) {
                ForEach(Array(pregunta.opciones.enumerated()), id: \.offset) { indice, texto in
                    OpcionBoton(letra: Formato.letras[indice],
                                texto: texto,
                                estado: vm.respuestaActual == indice ? .seleccionada : .normal) {
                        vm.seleccionar(indice)
                        Haptica.seleccion()
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        vm.anterior()
                    } label: {
                        Label("Anterior", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(vm.esPrimera)

                    if vm.esUltima {
                        Button {
                            pidiendoCorregir = true
                        } label: {
                            Text("Corregir")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button {
                            vm.siguiente()
                        } label: {
                            HStack {
                                Text("Siguiente")
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .controlSize(.large)
            }
            .padding()
            .background(.bar)
        }
        .id(vm.indiceActual)
    }

    // MARK: - Tiempo

    /// Cada segundo comprueba si se ha acabado el tiempo.
    /// Si se acaba, corrige automáticamente (como en el examen real).
    private func vigilarTiempo() async {
        while !vm.corregido && !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            if vm.segundosRestantes() == 0 && !vm.corregido {
                vm.corregir(contexto: contexto, porTiempo: true)
                Haptica.fallo()
            }
        }
    }
}

/// Cronómetro de la barra superior. "TimelineView" redibuja cada segundo.
struct CronometroView: View {
    let vm: SimulacroViewModel

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { contexto in
            let quedan = vm.segundosRestantes(en: contexto.date)
            Label(Formato.minutosSegundos(quedan), systemImage: "timer")
                .font(.headline.monospacedDigit())
                .foregroundStyle(quedan < 120 ? Color.red : Color.primary)   // rojo los 2 últimos minutos
        }
    }
}
