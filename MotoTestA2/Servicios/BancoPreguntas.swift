// BancoPreguntas.swift
// ------------------------------------------------------------------
// Carga las preguntas y las tiene en memoria para toda la app.
//
// El banco final se forma así:
//   1. Se leen las preguntas incluidas en la app (preguntas.json).
//   2. Encima se aplican las importadas (preguntas_importadas.json,
//      en la carpeta Documentos de la app):
//        - mismo id  → la importada sustituye a la incluida
//        - id nuevo  → se añade
// Así, al actualizar la app con preguntas nuevas, no pierdes las tuyas.
//
// Es TOLERANTE a errores: una pregunta mal formada se descarta, se
// apunta un aviso y el resto sigue funcionando.
//
// "@Observable": cuando cambia una propiedad, las vistas que la usan
// se redibujan solas.
// ------------------------------------------------------------------

import Foundation
import Observation

/// Resumen que se muestra tras importar un fichero.
struct ResultadoImportacion {
    let anadidas: Int
    let actualizadas: Int
    let avisos: [String]   // preguntas descartadas y por qué
}

enum ErrorImportacion: LocalizedError {
    case sinPreguntasValidas([String])

    var errorDescription: String? {
        switch self {
        case .sinPreguntasValidas(let avisos):
            let detalle = avisos.prefix(3).joined(separator: "\n")
            return "El fichero no contiene ninguna pregunta válida.\n\(detalle)"
        }
    }
}

@Observable
final class BancoPreguntas {
    private(set) var preguntas: [Pregunta] = []
    private(set) var origen = "—"
    private(set) var avisos: [String] = []
    private(set) var numIncluidas = 0
    private(set) var numImportadas = 0

    /// Fichero donde se guardan las preguntas importadas.
    static var urlImportado: URL {
        URL.documentsDirectory.appending(path: "preguntas_importadas.json")
    }

    init() {
        cargar()
    }

    // MARK: - Carga

    func cargar() {
        avisos = []
        var lista: [Pregunta] = []

        // 1. Banco incluido en la app
        if let url = Bundle.main.url(forResource: "preguntas", withExtension: "json"),
           let datos = try? Data(contentsOf: url) {
            let (validas, problemas) = Self.decodificar(datos, etiqueta: "banco incluido")
            lista = validas
            avisos += problemas
        } else {
            avisos.append("No se encontró preguntas.json dentro de la app.")
        }
        numIncluidas = lista.count

        // 2. Preguntas importadas por encima
        let importadas = leerImportadas()
        numImportadas = importadas.count
        lista = Self.fusionar(lista, con: importadas)

        preguntas = lista
        origen = importadas.isEmpty
            ? "Banco incluido en la app"
            : "Incluido + \(importadas.count) importadas"
    }

    // MARK: - Consultas

    func pregunta(id: String) -> Pregunta? {
        preguntas.first { $0.id == id }
    }

    func preguntas(de temas: Set<Tema>) -> [Pregunta] {
        preguntas.filter { temas.contains($0.tema) }
    }

    func cuantas(de tema: Tema) -> Int {
        preguntas.filter { $0.tema == tema }.count
    }

    // MARK: - Importar / exportar

    /// Importa un JSON elegido en la app Archivos y lo fusiona por id.
    func importar(desde url: URL) throws -> ResultadoImportacion {
        // Los ficheros de Archivos están fuera de la app: hay que pedir permiso para leerlos
        let acceso = url.startAccessingSecurityScopedResource()
        defer { if acceso { url.stopAccessingSecurityScopedResource() } }

        let datos = try Data(contentsOf: url)
        let (nuevas, problemas) = Self.decodificar(datos, etiqueta: "fichero")
        guard !nuevas.isEmpty else { throw ErrorImportacion.sinPreguntasValidas(problemas) }

        let idsActuales = Set(preguntas.map(\.id))
        let actualizadas = nuevas.filter { idsActuales.contains($0.id) }.count

        // Se suman a las que ya habías importado antes
        let guardadas = Self.fusionar(leerImportadas(), con: nuevas)
        try Self.codificador.encode(guardadas).write(to: Self.urlImportado, options: .atomic)

        cargar()
        return ResultadoImportacion(anadidas: nuevas.count - actualizadas,
                                    actualizadas: actualizadas,
                                    avisos: problemas)
    }

    /// Borra las preguntas importadas y vuelve al banco original.
    func restablecer() {
        try? FileManager.default.removeItem(at: Self.urlImportado)
        cargar()
    }

    /// Escribe el banco completo en un fichero temporal para compartirlo
    /// (sirve como copia y como plantilla para crear preguntas en el PC).
    func exportar() throws -> URL {
        let url = URL.temporaryDirectory.appending(path: "MotoTestA2-banco.json")
        try Self.codificador.encode(preguntas).write(to: url, options: .atomic)
        return url
    }

    // MARK: - Internos

    private static var codificador: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        return encoder
    }

    private func leerImportadas() -> [Pregunta] {
        guard let datos = try? Data(contentsOf: Self.urlImportado) else { return [] }
        let (validas, problemas) = Self.decodificar(datos, etiqueta: "banco importado")
        avisos += problemas
        return validas
    }

    /// Une dos listas: las de "nuevas" sustituyen (mismo id) o se añaden.
    private static func fusionar(_ base: [Pregunta], con nuevas: [Pregunta]) -> [Pregunta] {
        var resultado = base
        var posicion: [String: Int] = [:]
        for (indice, pregunta) in resultado.enumerated() {
            posicion[pregunta.id] = indice
        }
        for pregunta in nuevas {
            if let indice = posicion[pregunta.id] {
                resultado[indice] = pregunta
            } else {
                posicion[pregunta.id] = resultado.count
                resultado.append(pregunta)
            }
        }
        return resultado
    }

    /// Convierte el JSON en preguntas válidas y una lista de problemas.
    private static func decodificar(_ datos: Data, etiqueta: String) -> ([Pregunta], [String]) {
        let brutas: [PreguntaTolerante]
        do {
            brutas = try JSONDecoder().decode([PreguntaTolerante].self, from: datos)
        } catch {
            return ([], ["No se pudo leer el \(etiqueta): debe ser una lista JSON [ {...}, {...} ]."])
        }

        var avisos: [String] = []
        var idsVistos = Set<String>()
        var validas: [Pregunta] = []

        for (indice, bruta) in brutas.enumerated() {
            guard let p = bruta.pregunta else {
                avisos.append("Pregunta nº \(indice + 1) del \(etiqueta): faltan campos o el tema no existe.")
                continue
            }
            guard p.esValida else {
                avisos.append("Pregunta \(p.id): debe tener 3 opciones y «correcta» entre 0 y 2.")
                continue
            }
            guard idsVistos.insert(p.id).inserted else {
                avisos.append("Id repetido en el \(etiqueta): \(p.id) (se usa la primera).")
                continue
            }
            validas.append(p)
        }
        return (validas, avisos)
    }
}

/// Intenta leer una Pregunta y, si falla, guarda nil en vez de dar error.
private struct PreguntaTolerante: Decodable {
    let pregunta: Pregunta?

    init(from decoder: Decoder) throws {
        pregunta = try? Pregunta(from: decoder)
    }
}
