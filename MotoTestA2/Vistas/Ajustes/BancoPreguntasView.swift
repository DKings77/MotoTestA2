// BancoPreguntasView.swift
// ------------------------------------------------------------------
// Listado de todas las preguntas cargadas, agrupadas por tema.
// Sirve para comprobar que el JSON se ha leído bien (fase 2) y para
// consultar el banco más adelante.
// ------------------------------------------------------------------

import SwiftUI

struct BancoPreguntasView: View {
    // Acceso al banco compartido (se inyecta en MotoTestA2App)
    @Environment(BancoPreguntas.self) private var banco

    var body: some View {
        List {
            // Una sección por tema, solo si tiene preguntas
            ForEach(Tema.allCases) { tema in
                let delTema = banco.preguntas.filter { $0.tema == tema }
                if !delTema.isEmpty {
                    Section {
                        ForEach(delTema) { pregunta in
                            NavigationLink {
                                DetallePreguntaView(pregunta: pregunta)
                            } label: {
                                HStack(alignment: .top, spacing: 10) {
                                    Text(pregunta.enunciado)
                                        .font(.subheadline)
                                        .lineLimit(3)
                                    if pregunta.imagen != nil {
                                        Spacer(minLength: 4)
                                        Image(systemName: "photo")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    } header: {
                        Label("\(tema.nombre) (\(delTema.count))", systemImage: tema.icono)
                    }
                }
            }
        }
        .navigationTitle("Banco: \(banco.preguntas.count)")
    }
}

/// Una pregunta completa, con la respuesta correcta marcada.
struct DetallePreguntaView: View {
    let pregunta: Pregunta

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(pregunta.tema.nombre, systemImage: pregunta.tema.icono)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let imagen = pregunta.imagen {
                    ImagenPregunta(referencia: imagen)
                        .frame(maxWidth: .infinity)
                }

                Text(pregunta.enunciado)
                    .font(.title3.weight(.semibold))

                // "enumerated()" da el índice (0, 1, 2) y el texto de cada opción
                ForEach(Array(pregunta.opciones.enumerated()), id: \.offset) { indice, texto in
                    let esCorrecta = indice == pregunta.correcta
                    HStack(alignment: .top) {
                        Text(["A", "B", "C"][indice]).bold()
                        Text(texto)
                        Spacer()
                        if esCorrecta {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(12)
                    .background(esCorrecta ? Color.green.opacity(0.15) : Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Explicación").font(.headline)
                    Text(pregunta.explicacion)
                        .foregroundStyle(.secondary)
                }

                Text("id: \(pregunta.id)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
        }
        .navigationTitle("Pregunta")
        .navigationBarTitleDisplayMode(.inline)
    }
}
