// InicioView.swift
// ------------------------------------------------------------------
// Pantalla de inicio con los 5 botones principales.
//
// - "NavigationStack" es el contenedor que permite ir a otras pantallas
//   y volver con el botón "atrás".
// - "@Query" lee datos de SwiftData y se actualiza SOLO cuando cambian.
//   Aquí lo usamos para mostrar cuántos tests y fallos hay guardados.
// - Los botones están en la parte inferior para llegar con el pulgar.
// ------------------------------------------------------------------

import SwiftUI
import SwiftData

struct InicioView: View {
    // Lectura automática de la base de datos
    @Query private var intentos: [Intento]
    @Query private var fallos: [FalloPendiente]
    // Banco de preguntas compartido (cargado desde el JSON)
    @Environment(BancoPreguntas.self) private var banco
    // Test abierto ahora mismo (nil = ninguno)
    @State private var testActivo: ConfigTest?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    cabecera

                    // Cada NavigationLink indica a qué Ruta ir al pulsarlo
                    // Simulacro: examen real, 20 preguntas repartidas por temas
                    Button {
                        empezarSimulacro()
                    } label: {
                        BotonMenu(titulo: "Simulacro",
                                  subtitulo: "20 preguntas · 20 min · máx. 2 fallos",
                                  icono: "stopwatch",
                                  color: .orange)
                    }
                    // Práctica: abre directamente 20 preguntas al azar
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
                                  subtitulo: "\(fallos.count) pendientes de repasar",
                                  icono: "xmark.circle",
                                  color: .red)
                    }
                    NavigationLink(value: Ruta.estadisticas) {
                        BotonMenu(titulo: "Estadísticas",
                                  subtitulo: "\(intentos.count) tests realizados",
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
                // Rueda de ajustes arriba a la derecha
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: Ruta.ajustes) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            // Qué pantalla abrir para cada ruta
            .navigationDestination(for: Ruta.self) { ruta in
                switch ruta {
                case .ajustes:
                    AjustesView()
                case .temas:
                    SeleccionTemasView()
                default:
                    PantallaProximamente(titulo: ruta.titulo)
                }
            }
            // Cuando "testActivo" tiene valor, se abre el test a pantalla completa
            .fullScreenCover(item: $testActivo) { config in
                if config.modo == .simulacro {
                    SimulacroView(preguntas: config.preguntas)
                } else {
                    TestView(config: config)
                }
            }
        }
    }

    /// Prepara un simulacro con preguntas de todos los temas.
    private func empezarSimulacro() {
        let preguntas = GeneradorTests.simulacro(de: banco.preguntas)
        guard !preguntas.isEmpty else { return }
        testActivo = ConfigTest(modo: .simulacro, preguntas: preguntas)
    }

    /// Prepara una práctica de 20 preguntas al azar de todo el banco.
    private func empezarPractica() {
        let preguntas = GeneradorTests.aleatorias(de: banco.preguntas,
                                                  cantidad: ReglasExamen.numPreguntas)
        guard !preguntas.isEmpty else { return }
        testActivo = ConfigTest(modo: .practica, preguntas: preguntas)
    }

    /// Bloque superior con el icono y una frase.
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

#Preview {
    InicioView()
        .modelContainer(for: [Intento.self, RespuestaRegistrada.self, FalloPendiente.self],
                        inMemory: true)
        .environment(BancoPreguntas())
}
