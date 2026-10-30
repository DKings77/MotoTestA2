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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    cabecera

                    // Cada NavigationLink indica a qué Ruta ir al pulsarlo
                    NavigationLink(value: Ruta.simulacro) {
                        BotonMenu(titulo: "Simulacro",
                                  subtitulo: "20 preguntas · 20 minutos",
                                  icono: "stopwatch",
                                  color: .orange)
                    }
                    NavigationLink(value: Ruta.practica) {
                        BotonMenu(titulo: "Práctica",
                                  subtitulo: "Corrección al momento, sin tiempo",
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
                default:
                    PantallaProximamente(titulo: ruta.titulo)
                }
            }
        }
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

#Preview {
    InicioView()
        .modelContainer(for: [Intento.self, RespuestaRegistrada.self, FalloPendiente.self],
                        inMemory: true)
}
