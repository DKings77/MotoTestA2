// EstadisticasView.swift
// ------------------------------------------------------------------
// Panel de progreso:
//   1. ¿Estoy listo? (5 últimos simulacros aprobados + 85 % en cada tema)
//   2. Resumen: tests, simulacros, % aprobados, media de fallos
//   3. Gráfico de los últimos 10 simulacros (Swift Charts)
//   4. % de acierto por tema
//   5. Historial de simulacros, con revisión de cada uno
// ------------------------------------------------------------------

import SwiftUI
import SwiftData
import Charts

struct EstadisticasView: View {
    @Environment(BancoPreguntas.self) private var banco
    @Environment(\.modelContext) private var contexto
    @Query(sort: \Intento.fecha, order: .reverse) private var intentos: [Intento]
    @Query private var respuestas: [RespuestaRegistrada]

    private var calc: CalculadoraEstadisticas {
        CalculadoraEstadisticas(intentos: intentos, respuestas: respuestas)
    }

    var body: some View {
        Group {
            if intentos.isEmpty {
                ContentUnavailableView("Sin datos todavía",
                                       systemImage: "chart.bar",
                                       description: Text("Haz algún test o simulacro y aquí verás tu progreso."))
            } else {
                let c = calc
                List {
                    seccionListo(c)
                    seccionResumen(c)
                    if !c.ultimos10.isEmpty { seccionGrafico(c) }
                    seccionTemas(c)
                    if !c.simulacros.isEmpty { seccionHistorial(c) }
                }
            }
        }
        .navigationTitle("Estadísticas")
    }

    // MARK: - ¿Estoy listo?

    private func seccionListo(_ c: CalculadoraEstadisticas) -> some View {
        Section {
            HStack(spacing: 14) {
                Image(systemName: c.estaListo ? "checkmark.seal.fill" : "hourglass")
                    .font(.system(size: 40))
                    .foregroundStyle(c.estaListo ? Color.green : Color.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(c.estaListo ? "¡Estás listo para el examen!" : "Aún no estás listo")
                        .font(.headline)
                    Text(c.estaListo ? "Cumples todos los criterios. ¡A por el APTO!" : "Sigue practicando hasta cumplir los dos criterios.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)

            criterio(ok: c.cumpleSimulacros,
                     texto: "Últimos 5 simulacros aprobados",
                     detalle: "\(c.aprobadosUltimos5)/\(ReglasExamen.simulacrosParaEstarListo)")
            criterio(ok: c.cumpleTemas,
                     texto: "85 % o más en todos los temas",
                     detalle: "\(c.temasSuperados)/\(Tema.allCases.count)")
        } header: {
            Text("¿Estoy listo?")
        } footer: {
            Text("Para que un tema cuente necesitas al menos \(ReglasExamen.minimoRespuestasPorTema) respuestas en él.")
        }
    }

    private func criterio(ok: Bool, texto: String, detalle: String) -> some View {
        HStack {
            Image(systemName: ok ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(ok ? Color.green : Color.secondary)
            Text(texto)
            Spacer()
            Text(detalle)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    // MARK: - Resumen

    private func seccionResumen(_ c: CalculadoraEstadisticas) -> some View {
        Section("Resumen") {
            LabeledContent("Tests realizados", value: "\(c.numTests)")
            LabeledContent("Simulacros", value: "\(c.numSimulacros)")
            if let p = c.porcentajeAprobados {
                LabeledContent("Simulacros aprobados") {
                    Text("\(c.numAprobados) · \(p.formatted(.percent.precision(.fractionLength(0))))")
                }
            }
            if let media = c.mediaFallos {
                LabeledContent("Media de fallos por simulacro",
                               value: media.formatted(.number.precision(.fractionLength(1))))
            }
        }
    }

    // MARK: - Gráfico

    private func seccionGrafico(_ c: CalculadoraEstadisticas) -> some View {
        let maxY = max(5, (c.ultimos10.map(\.fallos).max() ?? 0) + 1)

        return Section {
            Chart {
                ForEach(c.ultimos10) { punto in
                    BarMark(x: .value("Simulacro", "\(punto.numero)"),
                            y: .value("Fallos", punto.fallos))
                        .foregroundStyle(punto.aprobado ? Color.green : Color.red)
                        .cornerRadius(4)
                        .annotation(position: .top) {
                            Text("\(punto.fallos)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                }
                // Línea del máximo permitido
                RuleMark(y: .value("Máximo", ReglasExamen.maxFallos))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.secondary)
                    .annotation(position: .top, alignment: .leading) {
                        Text("máx. \(ReglasExamen.maxFallos)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
            }
            .chartYScale(domain: 0...maxY)
            .frame(height: 190)
            .padding(.vertical, 8)
        } header: {
            Text("Fallos en los últimos simulacros")
        } footer: {
            Text("Verde: APTO · Rojo: NO APTO. El más reciente, a la derecha.")
        }
    }

    // MARK: - Por tema

    private func seccionTemas(_ c: CalculadoraEstadisticas) -> some View {
        Section("Acierto por tema") {
            ForEach(c.porTema) { e in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label(e.tema.nombre, systemImage: e.tema.icono)
                            .font(.subheadline)
                        Spacer()
                        if let p = e.porcentaje {
                            Text(p.formatted(.percent.precision(.fractionLength(0))))
                                .font(.subheadline.bold().monospacedDigit())
                                .foregroundStyle(color(para: e))
                        } else {
                            Text("—").foregroundStyle(.secondary)
                        }
                    }
                    ProgressView(value: e.porcentaje ?? 0)
                        .tint(color(para: e))
                    Text(e.respondidas == 0
                         ? "Sin respuestas"
                         : "\(e.aciertos) de \(e.respondidas) correctas")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func color(para e: EstadisticaTema) -> Color {
        guard let p = e.porcentaje else { return .secondary }
        if p >= ReglasExamen.aciertoMinimoPorTema { return .green }
        if p >= 0.7 { return .orange }
        return .red
    }

    // MARK: - Historial

    private func seccionHistorial(_ c: CalculadoraEstadisticas) -> some View {
        Section {
            ForEach(c.simulacros) { intento in
                NavigationLink {
                    RevisionView(items: itemsRevision(de: intento))
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(intento.fecha.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                            Text("\(intento.numFallos) fallos · \(Formato.minutosSegundos(intento.duracionSegundos))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        let apto = intento.aprobado == true
                        Text(apto ? "APTO" : "NO APTO")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((apto ? Color.green : Color.red).opacity(0.15), in: Capsule())
                            .foregroundStyle(apto ? Color.green : Color.red)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        contexto.delete(intento)
                    } label: {
                        Label("Borrar", systemImage: "trash")
                    }
                }
            }
        } header: {
            Text("Historial de simulacros")
        } footer: {
            Text("Toca uno para revisarlo. Desliza a la izquierda para borrarlo.")
        }
    }

    /// Reconstruye la revisión de un simulacro guardado con las preguntas del banco.
    private func itemsRevision(de intento: Intento) -> [ItemRevision] {
        intento.respuestasOrdenadas.compactMap { r in
            guard let pregunta = banco.pregunta(id: r.preguntaID) else { return nil }
            return ItemRevision(numero: r.orden + 1, pregunta: pregunta, elegida: r.elegida)
        }
    }
}
