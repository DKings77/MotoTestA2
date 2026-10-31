// CaducidadApp.swift
// ------------------------------------------------------------------
// Con un Apple ID gratuito, la app caduca a los 7 días de instalarla.
// Sideloadly mete dentro de la app un fichero "embedded.mobileprovision"
// que contiene la fecha de caducidad. Lo leemos para avisarte.
//
// Ese fichero es una firma digital con una lista de datos (plist) en
// texto dentro: buscamos el trozo entre "<?xml" y "</plist>".
// Si no existe (p. ej. en la vista previa), devuelve nil y no se avisa.
// ------------------------------------------------------------------

import Foundation

enum CaducidadApp {
    /// Fecha en la que la instalación deja de abrirse.
    static let fecha: Date? = {
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
              let datos = try? Data(contentsOf: url),
              let inicio = datos.range(of: Data("<?xml".utf8)),
              let fin = datos.range(of: Data("</plist>".utf8), in: inicio.lowerBound..<datos.endIndex)
        else { return nil }

        let plist = datos.subdata(in: inicio.lowerBound..<fin.upperBound)
        let diccionario = try? PropertyListSerialization.propertyList(from: plist,
                                                                     options: [],
                                                                     format: nil) as? [String: Any]
        return diccionario?["ExpirationDate"] as? Date
    }()

    /// Días que quedan (0 = caduca hoy).
    static var diasRestantes: Int? {
        guard let fecha else { return nil }
        return max(0, Calendar.current.dateComponents([.day], from: .now, to: fecha).day ?? 0)
    }
}
