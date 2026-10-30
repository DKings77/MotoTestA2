// ResultadoSimulacroView.swift
// ------------------------------------------------------------------
// Resultado del simulacro: APTO / NO APTO, fallos, tiempo y acceso
// a la revisión pregunta a pregunta.
// ------------------------------------------------------------------

import SwiftUI

struct ResultadoSimulacroView: View {
    let vm: SimulacroViewModel
    let alCerrar: () -> Void

    private var color: Color { vm.aprobado ? .green : .red }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: vm.aprobado ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(color)
                    .padding(.top, 24)

                Text(vm.aprobado ? "APTO" : "NO APTO")
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .foregroundStyle(color)

                Text("\(vm.numFallos) \(vm.numFallos == 1 ? "fallo" : "fallos") · máximo permitido: \(ReglasExamen.maxFallos)")
                    .foregroundStyle(.secondary)

                if vm.acabadoPorTiempo {
                    Label("Se acabó el tiempo", systemImage: "timer")
                        .foregroundStyle(.orange)
                        .font(.headline)
                }

                // Datos en 4 casillas
                HStack(spacing: 10) {
                    dato("Aciertos", "\(vm.numAciertos)")
                    dato("Fallos", "\(vm.numFallos)")
                    dato("En blanco", "\(vm.sinResponder)")
                    dato("Tiempo", Formato.minutosSegundos(vm.segundosUsados))
                }

                NavigationLink {
                    RevisionView(items: vm.itemsRevision)
                } label: {
                    Label("Revisar respuestas", systemImage: "list.bullet.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
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

    private func dato(_ titulo: String, _ valor: String) -> some View {
        VStack(spacing: 4) {
            Text(valor)
                .font(.title3.bold().monospacedDigit())
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 12))
    }
}
