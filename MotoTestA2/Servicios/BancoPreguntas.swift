// BancoPreguntas.swift
// ------------------------------------------------------------------
// Carga las preguntas desde JSON y las tiene en memoria para toda la app.
//
// Orden de carga:
//   1. Si has importado un banco (fase 7), se guarda como
//      "preguntas_importadas.json" en la carpeta Documentos de la app
//      y se usa ese.
//   2. Si no, se usa "preguntas.json", incluido dentro de la app.
//
// Es TOLERANTE a errores: si una pregunta del JSON está mal (tema que
// no existe, 2 opciones, id repetido…) se descarta, se apunta un aviso
// y el resto sigue funcionando. Los avisos se ven en Ajustes.
//
// "@Observable" (iOS 17): cuando cambia una propiedad, las vistas que
// la usan se redibujan solas. Es como un "INotifyPropertyChanged".
// ------------------------------------------------------------------

import Foundation
import Observation

@Observable
final class BancoPreguntas {
    /// Todas las preguntas válidas cargadas.
    private(set) var preguntas: [Pregunta] = []
    /// Texto que indica de dónde salen las preguntas.
    private(set) var origen: String = "—"
    /// Problemas encontrados al cargar (preguntas descartadas, etc.).
    private(set) var avisos: [String] = []

    /// Ruta del banco importado dentro de la app.
    static var urlImportado: URL {
        URL.documentsDirectory.appending(path: "preguntas_importadas.json")
    }

    init() {
        cargar()
    }

    /// Lee el banco (importado o incluido) y rellena "preguntas".
    func cargar() {
        avisos = []

        // 1. ¿Hay un banco importado?
        if FileManager.default.fileExists(atPath: Self.urlImportado.path()),
           let lista = leer(url: Self.urlImportado, etiqueta: "banco importado"),
           !lista.isEmpty {
            preguntas = lista
            origen = "Banco importado"
            return
        }

        // 2. Si no, el incluido en la app
        if let url = Bundle.main.url(forResource: "preguntas", withExtension: "json"),
           let lista = leer(url: url, etiqueta: "banco incluido") {
            preguntas = lista
            origen = "Banco incluido en la app"
        } else {
            preguntas = []
            origen = "Sin preguntas"
            avisos.append("No se encontró preguntas.json dentro de la app.")
        }
    }

    // MARK: - Consultas útiles para las siguientes fases

    /// Busca una pregunta por su id (para repasar fallos e historial).
    func pregunta(id: String) -> Pregunta? {
        preguntas.first { $0.id == id }
    }

    /// Preguntas de los temas indicados.
    func preguntas(de temas: Set<Tema>) -> [Pregunta] {
        preguntas.filter { temas.contains($0.tema) }
    }

    /// Cuántas preguntas hay de un tema.
    func cuantas(de tema: Tema) -> Int {
        preguntas.filter { $0.tema == tema }.count
    }

    // MARK: - Lectura del fichero

    /// Lee un fichero JSON y devuelve las preguntas válidas,
    /// o nil si el fichero no se puede leer en absoluto.
    private func leer(url: URL, etiqueta: String) -> [Pregunta]? {
        do {
            let datos = try Data(contentsOf: url)
            // Decodificamos pregunta a pregunta para que una mala no tumbe a todas
            let brutas = try JSONDecoder().decode([PreguntaTolerante].self, from: datos)

            var idsVistos = Set<String>()
            var validas: [Pregunta] = []

            for (indice, bruta) in brutas.enumerated() {
                guard let p = bruta.pregunta else {
                    avisos.append("Pregunta nº \(indice + 1) del \(etiqueta): formato incorrecto o tema desconocido.")
                    continue
                }
                guard p.esValida else {
                    avisos.append("Pregunta \(p.id): debe tener 3 opciones y 'correcta' entre 0 y 2.")
                    continue
                }
                guard idsVistos.insert(p.id).inserted else {
                    avisos.append("Id repetido: \(p.id) (se usa la primera).")
                    continue
                }
                validas.append(p)
            }
            return validas
        } catch {
            avisos.append("No se pudo leer el \(etiqueta): \(error.localizedDescription)")
            return nil
        }
    }
}

/// Envoltorio que intenta leer una Pregunta y, si falla, guarda nil
/// en lugar de lanzar un error.
private struct PreguntaTolerante: Decodable {
    let pregunta: Pregunta?

    init(from decoder: Decoder) throws {
        pregunta = try? Pregunta(from: decoder)
    }
}
