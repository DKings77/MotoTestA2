// TestView.swift
// ------------------------------------------------------------------
// Pantalla donde se hacen las preguntas (modos práctica y por temas).
// Se abre a pantalla completa; para salir hay que confirmarlo.
//
// Distribución pensada para una mano:
//   - Arriba (con scroll): progreso, imagen, enunciado y explicación.
//   - Abajo (fijo): las 3 respuestas y el botón "Siguiente".
// ------------------------------------------------------------------

import SwiftUI
import SwiftData

struct TestView: View {
    @Environment(\.dismiss) private var dismiss          // para cerrar la pantalla
    @Environment(\.modelContext) private var contexto    // base de datos

    // "@State" con una clase @Observable: la vista se redibuja sola
    // cuando cambia algo del ViewModel.
    @State private var vm: TestViewModel
    @State private var pidiendoSalir = false
    @State private var guardado = false

    init(config: ConfigTest) {
        _vm = State(initialValue: TestViewModel(modo: config.modo, preguntas: config.preguntas))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.terminado {
                    ResumenPracticaView(vm: vm) { dismiss() }
                } else {
                    contenidoPregunta
                }
            }
            .navigationTitle(vm.modo.nombre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !vm.terminado {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            pidiendoSalir = true
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
            .confirmationDialog("¿Abandonar el test?",
                                isPresented: $pidiendoSalir,
                                titleVisibility: .visible) {
                Button("Abandonar", role: .destructive) { dismiss() }
                Button("Seguir", role: .cancel) { }
            } message: {
                Text("Lo que ya hayas fallado queda en «Mis fallos», pero el test no se guardará en las estadísticas.")
            }
            // Al terminar, se guarda el test una sola vez
            .onChange(of: vm.terminado) { _, terminado in
                if terminado && !guardado {
                    vm.guardar(en: contexto)
                    guardado = true
                }
            }
        }
    }

    // MARK: - Pregunta en curso

    private var contenidoPregunta: some View {
        let pregunta = vm.preguntaActual

        return VStack(spacing: 0) {
            ProgressView(value: vm.progreso)
                .padding(.horizontal)
                .padding(.top, 4)

            // Zona superior con scroll
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Pregunta \(vm.indiceActual + 1) de \(vm.preguntas.count)")
                        Spacer()
                        Label(pregunta.tema.nombre, systemImage: pregunta.tema.icono)
                            .lineLimit(1)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if let imagen = pregunta.imagen {
                        ImagenPregunta(referencia: imagen)
                            .frame(maxWidth: .infinity)
                    }

                    Text(pregunta.enunciado)
                        .font(.title3.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    if vm.yaRespondida {
                        cajaExplicacion(pregunta)
                    }
                }
                .padding()
            }

            // Zona inferior fija: respuestas al alcance del pulgar
            VStack(spacing: 10) {
                ForEach(Array(pregunta.opciones.enumerated()), id: \.offset) { indice, texto in
                    OpcionBoton(letra: ["A", "B", "C"][indice],
                                texto: texto,
                                estado: estado(de: indice)) {
                        pulsar(indice)
                    }
                }

                if vm.yaRespondida {
                    Button {
                        withAnimation { vm.siguiente() }
                    } label: {
                        Text(vm.esUltima ? "Ver resultado" : "Siguiente")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding()
            .background(.bar)
        }
        .id(vm.indiceActual)   // al cambiar de pregunta, el scroll vuelve arriba
    }

    // MARK: - Lógica de la vista

    /// Al pulsar una respuesta: se registra y vibra según acierto/fallo.
    private func pulsar(_ indice: Int) {
        guard let acierto = vm.responder(indice, contexto: contexto) else { return }
        if acierto {
            Haptica.acierto()
        } else {
            Haptica.fallo()
        }
    }

    /// Calcula cómo se pinta cada botón de respuesta.
    private func estado(de indice: Int) -> EstadoOpcion {
        guard let elegida = vm.respuestaActual else { return .normal }
        let correcta = vm.preguntaActual.correcta
        if indice == elegida {
            return indice == correcta ? .acierto : .fallo
        }
        if indice == correcta { return .correctaNoElegida }
        return .apagada
    }

    /// Recuadro verde/rojo con la explicación.
    private func cajaExplicacion(_ pregunta: Pregunta) -> some View {
        let acierto = vm.respuestaActual == pregunta.correcta
        let letraCorrecta = ["A", "B", "C"][pregunta.correcta]

        return VStack(alignment: .leading, spacing: 6) {
            Label(acierto ? "¡Correcto!" : "Incorrecto. La respuesta correcta es la \(letraCorrecta).",
                  systemImage: acierto ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.headline)
                .foregroundStyle(acierto ? Color.green : Color.red)
            Text(pregunta.explicacion)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background((acierto ? Color.green : Color.red).opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 14))
    }
}
