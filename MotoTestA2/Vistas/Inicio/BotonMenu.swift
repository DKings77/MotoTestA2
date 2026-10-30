// BotonMenu.swift
// ------------------------------------------------------------------
// Diseño de cada botón grande de la pantalla de inicio.
// Es una vista reutilizable: recibe título, subtítulo, icono y color.
// ------------------------------------------------------------------

import SwiftUI

struct BotonMenu: View {
    let titulo: String
    let subtitulo: String
    let icono: String
    let color: Color

    var body: some View {
        // HStack coloca los elementos en horizontal
        HStack(spacing: 16) {
            // Icono en un cuadrado redondeado de color
            Image(systemName: icono)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 14))

            // Textos uno encima del otro, alineados a la izquierda
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.headline)
                Text(subtitulo)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()   // empuja la flecha a la derecha

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 18))
        .contentShape(Rectangle())   // toda la tarjeta es pulsable
    }
}
