// InicioView.swift
// ------------------------------------------------------------------
// Pantalla de inicio con los 5 botones principales.
//
// - "NavigationStack" permite ir a otras pantallas y volver.
// - "@Query" lee SwiftData y se actualiza solo cuando cambian los datos.
// - Simulacro y Práctica se abren a pantalla completa (fullScreenCover);
//   Por temas, Mis fallos y Estadísticas se abren dentro de la navegación.
// ------------------------------------------------------------------

import SwiftUI
import SwiftData

struct InicioView: View {
    @Query private var intentos: [Intento]
    @Query private var fallos: [FalloPendiente]
    @Environment(BancoPreguntas.self) private var banco
    @State private var testActivo: ConfigTest?   // test abierto (nil = ninguno)

    private var simulacros: [Intento] { intentos.filter { $0.modo == .simulacro } }
    private var aprobados: Int { simulacros.filter { $0.aprobado == true }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    cabecera

                    Button {
                        empezarSimulacro()
                    } label: {
                        BotonMenu(titulo: "Simulacro",
                                  subtitulo: "20 preguntas · 20 min · máx. 2 fallos",
                                  icono: "stopwatch",
                                  color: .orange)
                    }
                    Button {
                        empezarPractica()
                    } label: {
                        BotonMenu(titulo: "Práctica",
                                  subtitulo: "20 al azar · corrección al momento",
                                  icono: "checklist",
                                  color: .blue)
                    }
                    NavigationLink(value: Ruta.temas) {
                        BotonMenu(titulo: "Por temas",
                                  subtitulo: "Elige uno o varios temas",
                                  icono: "square.grid.2x2",
                                  color: .purple)
                    }
                    NavigationLink(value: Ruta.fallos) {
                        BotonMenu(titulo: "Mis fallos",
                                  subtitulo: fallos.isEmpty ? "Nada pendiente 👌" : "\(fallos.count) pendientes de repasar",
                                  icono: "xmark.circle",
                                  color: .red)
                    }
                    NavigationLink(value: Ruta.estadisticas) {
                        BotonMenu(titulo: "Estadísticas",
                                  subtitulo: simulacros.isEmpty
                                    ? "\(intentos.count) tests realizados"
                                    : "\(aprobados) de \(simulacros.count) simulacros aprobados",
                                  icono: "chart.bar",
                                  color: .green)
                    }
                }
                .buttonStyle(.plain)   // quita el estilo azul por defecto de los enlaces
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("MotoTest A2")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: Ruta.ajustes) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: Ruta.self) { ruta in
                switch ruta {
                case .ajustes:      AjustesView()
                case .temas:        SeleccionTemasView()
                case .fallos:       MisFallosView()
                case .estadisticas: EstadisticasView()
                case .simulacro, .practica: EmptyView()   // se abren a pantalla completa
                }
            }
            .fullScreenCover(item: $testActivo) { config in
                if config.modo == .simulacro {
                    SimulacroView(preguntas: config.preguntas)
                } else {
                    TestView(config: config)
                }
            }
        }
    }

    /// Bloque superior: icono, nº de preguntas y aviso de caducidad.
    private var cabecera: some View {
        VStack(spacing: 8) {
            Image(systemName: "steeringwheel")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
            Text("Teórico específico de moto · Permiso A2")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(banco.preguntas.count) preguntas en el banco")
                .font(.caption)
                .foregroundStyle(.tertiary)

            if let dias = CaducidadApp.diasRestantes {
                Label(dias == 0 ? "La instalación caduca hoy: reinstala con Sideloadly"
                                : "Instalación válida \(dias) \(dias == 1 ? "día" : "días") más",
                      systemImage: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(dias <= 1 ? Color.orange : Color.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    /// Simulacro con preguntas repartidas entre todos los temas.
    private func empezarSimulacro() {
        let preguntas = GeneradorTests.simulacro(de: banco.preguntas)
        guard !preguntas.isEmpty else { return }
        testActivo = ConfigTest(modo: .simulacro, preguntas: preguntas)
    }

    /// Práctica de 20 preguntas al azar de todo el banco.
    private func empezarPractica() {
        let preguntas = GeneradorTests.aleatorias(de: banco.preguntas,
                                                  cantidad: ReglasExamen.numPreguntas)
        guard !preguntas.isEmpty else { return }
        testActivo = ConfigTest(modo: .practica, preguntas: preguntas)
    }
}

#Preview {
    InicioView()
        .modelContainer(for: [Intento.self, RespuestaRegistrada.self, FalloPendiente.self],
                        inMemory: true)
        .environment(BancoPreguntas())
}
