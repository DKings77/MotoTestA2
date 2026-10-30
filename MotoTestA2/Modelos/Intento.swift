// Intento.swift
// ------------------------------------------------------------------
// Un test terminado (de cualquier modo). Se guarda en SwiftData.
//
// - "@Model" convierte la clase en una tabla de la base de datos.
//   Cada propiedad es una columna. No hay que escribir SQL.
// - Las clases de SwiftData deben ser "final class" (no struct).
// - Guardamos el modo como texto (modoRaw) porque SwiftData filtra
//   mejor tipos simples; "modo" es un atajo cómodo para leerlo.
// - "@Relationship(deleteRule: .cascade)": si borras un intento, se
//   borran también sus respuestas.
// ------------------------------------------------------------------

import Foundation
import SwiftData

@Model
final class Intento {
    var fecha: Date
    var modoRaw: String
    var duracionSegundos: Int
    var numPreguntas: Int
    var numFallos: Int
    var aprobado: Bool?          // solo tiene valor en simulacros

    @Relationship(deleteRule: .cascade, inverse: \RespuestaRegistrada.intento)
    var respuestas: [RespuestaRegistrada] = []

    /// El modo como enum (más cómodo que el texto).
    var modo: ModoTest { ModoTest(rawValue: modoRaw) ?? .practica }

    /// Respuestas en el orden en que se hicieron las preguntas
    /// (SwiftData no garantiza el orden del array por sí solo).
    var respuestasOrdenadas: [RespuestaRegistrada] {
        respuestas.sorted { $0.orden < $1.orden }
    }

    init(fecha: Date = .now,
         modo: ModoTest,
         duracionSegundos: Int,
         numPreguntas: Int,
         numFallos: Int,
         aprobado: Bool? = nil) {
        self.fecha = fecha
        self.modoRaw = modo.rawValue
        self.duracionSegundos = duracionSegundos
        self.numPreguntas = numPreguntas
        self.numFallos = numFallos
        self.aprobado = aprobado
    }
}
