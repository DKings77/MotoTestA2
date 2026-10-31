// AjustesView.swift
// ------------------------------------------------------------------
// Ajustes:
//   - Banco de preguntas: origen, total y listado completo.
//   - Ampliar el banco: importar un JSON desde Archivos, exportar el
//     banco actual (copia o plantilla) y quitar las importadas.
//   - Datos: borrar historial / vaciar Mis fallos.
//   - Acerca de: versión y fecha de caducidad de la instalación.
// ------------------------------------------------------------------

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct AjustesView: View {
    @Environment(\.modelContext) private var contexto
    @Environment(BancoPreguntas.self) private var banco
    @Query private var intentos: [Intento]
    @Query private var fallos: [FalloPendiente]

    @State private var importando = false
    @State private var mensaje: String?
    @State private var urlExportacion: URL?
    @State private var confirmarRestablecer = false
    @State private var confirmarBorrarHistorial = false
    @State private var confirmarBorrarFallos = false

    private var versionApp: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var body: some View {
        List {
            // --- Banco ---
            Section("Banco de preguntas") {
                LabeledContent("Origen", value: banco.origen)
                LabeledContent("Preguntas", value: "\(banco.preguntas.count)")
                NavigationLink("Ver todas las preguntas") {
                    BancoPreguntasView()
                }
            }

            // --- Ampliar ---
            Section {
                Button {
                    importando = true
                } label: {
                    Label("Importar preguntas (JSON)", systemImage: "square.and.arrow.down")
                }
                if let urlExportacion {
                    ShareLink(item: urlExportacion) {
                        Label("Exportar banco actual", systemImage: "square.and.arrow.up")
                    }
                }
                if banco.numImportadas > 0 {
                    Button(role: .destructive) {
                        confirmarRestablecer = true
                    } label: {
                        Label("Quitar las \(banco.numImportadas) preguntas importadas", systemImage: "arrow.uturn.backward")
                    }
                }
            } header: {
                Text("Ampliar el banco")
            } footer: {
                Text("Importa un .json desde Archivos (iCloud Drive, En mi iPhone…). Si una pregunta tiene un id que ya existe, se actualiza; si es nueva, se añade. Exporta el banco para tener una copia o usarlo como plantilla.")
            }

            // --- Avisos de carga ---
            if !banco.avisos.isEmpty {
                Section("Avisos al cargar (\(banco.avisos.count))") {
                    ForEach(banco.avisos, id: \.self) { aviso in
                        Label(aviso, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                }
            }

            // --- Datos ---
            Section {
                LabeledContent("Tests guardados", value: "\(intentos.count)")
                LabeledContent("Fallos pendientes", value: "\(fallos.count)")
                Button("Borrar historial y estadísticas", role: .destructive) {
                    confirmarBorrarHistorial = true
                }
                Button("Vaciar «Mis fallos»", role: .destructive) {
                    confirmarBorrarFallos = true
                }
            } header: {
                Text("Mis datos")
            }

            // --- Acerca de ---
            Section {
                LabeledContent("Versión", value: versionApp)
                if let fecha = CaducidadApp.fecha {
                    LabeledContent("La instalación caduca") {
                        Text(fecha.formatted(date: .abbreviated, time: .shortened))
                    }
                }
            } header: {
                Text("Acerca de")
            } footer: {
                Text("Con un Apple ID gratuito la app caduca a los 7 días. Vuelve a instalarla con Sideloadly antes de esa fecha: tus datos se conservan.")
            }
        }
        .navigationTitle("Ajustes")
        // Selector de ficheros de iOS
        .fileImporter(isPresented: $importando, allowedContentTypes: [.json]) { resultado in
            importar(resultado)
        }
        // Mensaje tras importar
        .alert("Importación",
               isPresented: Binding(get: { mensaje != nil }, set: { if !$0 { mensaje = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(mensaje ?? "")
        }
        .confirmationDialog("¿Quitar las preguntas importadas?",
                            isPresented: $confirmarRestablecer, titleVisibility: .visible) {
            Button("Quitar", role: .destructive) { banco.restablecer() }
        } message: {
            Text("Se volverá al banco incluido en la app. Tu historial no se borra.")
        }
        .confirmationDialog("¿Borrar todo el historial?",
                            isPresented: $confirmarBorrarHistorial, titleVisibility: .visible) {
            Button("Borrar historial", role: .destructive) {
                intentos.forEach { contexto.delete($0) }
            }
        } message: {
            Text("Se borran todos los tests y las estadísticas. «Mis fallos» se mantiene.")
        }
        .confirmationDialog("¿Vaciar «Mis fallos»?",
                            isPresented: $confirmarBorrarFallos, titleVisibility: .visible) {
            Button("Vaciar", role: .destructive) {
                fallos.forEach { contexto.delete($0) }
            }
        }
        // Prepara el fichero de exportación (y lo rehace si cambia el banco)
        .task(id: banco.preguntas.count) {
            urlExportacion = try? banco.exportar()
        }
    }

    private func importar(_ resultado: Result<URL, Error>) {
        switch resultado {
        case .success(let url):
            do {
                let r = try banco.importar(desde: url)
                var texto = "Nuevas: \(r.anadidas)\nActualizadas: \(r.actualizadas)\nTotal en el banco: \(banco.preguntas.count)"
                if !r.avisos.isEmpty {
                    texto += "\n\nDescartadas: \(r.avisos.count)\n" + r.avisos.prefix(3).joined(separator: "\n")
                }
                mensaje = texto
            } catch {
                mensaje = error.localizedDescription
            }
        case .failure(let error):
            mensaje = error.localizedDescription
        }
    }
}
