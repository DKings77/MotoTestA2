// ImagenPregunta.swift
// ------------------------------------------------------------------
// Muestra la imagen de una pregunta. El campo "imagen" del JSON admite:
//   - El nombre de una imagen incluida en la app: "senal_r2"
//     (también vale "senal_r2.png"; se quita la extensión).
//   - Una imagen incrustada en base64: "data:image/png;base64,iVBOR..."
//     Así un JSON importado puede traer sus propias imágenes.
// ------------------------------------------------------------------

import SwiftUI
import UIKit

struct ImagenPregunta: View {
    let referencia: String

    var body: some View {
        if let imagen = Self.cargar(referencia) {
            Image(uiImage: imagen)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .accessibilityLabel("Imagen de la pregunta")
        } else {
            Label("Imagen no encontrada: \(referencia)", systemImage: "photo")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    /// Convierte la referencia del JSON en una imagen.
    static func cargar(_ referencia: String) -> UIImage? {
        // Caso 1: imagen incrustada en base64
        if referencia.hasPrefix("data:"), let coma = referencia.firstIndex(of: ",") {
            let base64 = String(referencia[referencia.index(after: coma)...])
            guard let datos = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
                return nil
            }
            return UIImage(data: datos)
        }

        // Caso 2: nombre de imagen de la app (quitamos .png / .jpg si viene)
        var nombre = referencia
        for extension_ in [".png", ".jpg", ".jpeg"] where nombre.lowercased().hasSuffix(extension_) {
            nombre = String(nombre.dropLast(extension_.count))
        }
        return UIImage(named: nombre)
    }
}
