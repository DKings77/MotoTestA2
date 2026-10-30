// Haptica.swift
// ------------------------------------------------------------------
// Vibraciones al responder: una suave de "éxito" al acertar y una
// doble de "error" al fallar. Son las mismas que usa iOS en el sistema.
// ------------------------------------------------------------------

import UIKit

enum Haptica {
    static func acierto() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func fallo() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    /// Toque suave al marcar una respuesta en el simulacro
    /// (ahí no se puede revelar si es acierto o fallo).
    static func seleccion() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
