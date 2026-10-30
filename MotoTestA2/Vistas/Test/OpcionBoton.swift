// OpcionBoton.swift
// ------------------------------------------------------------------
// Botón grande de cada respuesta (A, B, C).
// Cambia de aspecto según su estado tras responder:
//   - normal              → gris, se puede pulsar
//   - acierto             → verde (la que elegiste y era correcta)
//   - fallo               → rojo  (la que elegiste y era incorrecta)
//   - correctaNoElegida   → borde verde (para que veas cuál era)
//   - apagada             → atenuada (ni elegida ni correcta)
// ------------------------------------------------------------------

import SwiftUI

enum EstadoOpcion {
    case normal, acierto, fallo, correctaNoElegida, apagada
}

struct OpcionBoton: View {
    let letra: String
    let texto: String
    let estado: EstadoOpcion
    let accion: () -> Void

    var body: some View {
        Button(action: accion) {
            HStack(alignment: .center, spacing: 12) {
                // Círculo con la letra
                Text(letra)
                    .font(.headline)
                    .frame(width: 34, height: 34)
                    .background(colorCirculo, in: Circle())
                    .foregroundStyle(colorLetra)

                Text(texto)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                if let icono {
                    Image(systemName: icono)
                        .font(.title3)
                        .foregroundStyle(colorEstado)
                }
            }
            .padding(14)
            .frame(minHeight: 64)
            .background(colorFondo, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(colorBorde, lineWidth: 2)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .opacity(estado == .apagada ? 0.45 : 1)
        .animation(.easeInOut(duration: 0.2), value: estado)
    }

    // MARK: - Colores según el estado

    private var colorEstado: Color {
        switch estado {
        case .acierto, .correctaNoElegida: return .green
        case .fallo: return .red
        default: return .secondary
        }
    }

    private var colorFondo: Color {
        switch estado {
        case .acierto: return Color.green.opacity(0.18)
        case .fallo: return Color.red.opacity(0.18)
        default: return Color(.secondarySystemGroupedBackground)
        }
    }

    private var colorBorde: Color {
        switch estado {
        case .acierto, .correctaNoElegida: return .green
        case .fallo: return .red
        default: return .clear
        }
    }

    private var colorCirculo: Color {
        switch estado {
        case .acierto, .correctaNoElegida: return .green
        case .fallo: return .red
        default: return Color(.tertiarySystemFill)
        }
    }

    private var colorLetra: Color {
        switch estado {
        case .acierto, .correctaNoElegida, .fallo: return .white
        default: return .primary
        }
    }

    private var icono: String? {
        switch estado {
        case .acierto, .correctaNoElegida: return "checkmark.circle.fill"
        case .fallo: return "xmark.circle.fill"
        default: return nil
        }
    }
}
