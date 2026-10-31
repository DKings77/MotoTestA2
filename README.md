# MotoTest A2

App de iPhone para preparar el examen teórico específico de moto (permiso A2, DGT).
SwiftUI · iOS 17 · SwiftData · 100 % offline, sin anuncios ni cuentas.

## Funciones

- **Simulacro**: 20 preguntas repartidas por temas, 20 minutos, máx. 2 fallos, sin ver la solución hasta corregir. Rejilla para saltar entre preguntas, resultado APTO / NO APTO y revisión.
- **Práctica** y **Por temas**: corrección al momento (verde/rojo), explicación y vibración.
- **Mis fallos**: cada pregunta fallada entra aquí y sale al acertarla 2 veces seguidas.
- **Estadísticas**: «¿Estoy listo?», % de aprobados, media de fallos, gráfico de los últimos 10 simulacros, % por tema e historial revisable.
- **Ajustes**: importar/exportar el banco en JSON, borrar datos y fecha de caducidad de la instalación.

## Cómo se compila (sin Mac)

1. `git push` a `main` → GitHub Actions (macOS) genera el proyecto con XcodeGen y compila un `.ipa` sin firmar.
2. Descargar el artifact **MotoTestA2-ipa** de la pestaña Actions.
3. Instalar con **Sideloadly** y el Apple ID (gratuito: caduca a los 7 días, se reinstala sin perder datos).

Atajo: `.\actualizar.ps1 "mensaje"` aplica el último zip descargado, hace push y espera a la compilación.

## Formato de las preguntas (JSON)

Lista de objetos. Se puede importar desde Ajustes → Importar preguntas.
Las preguntas con un `id` existente se actualizan; las nuevas se añaden.

```json
[
  {
    "id": "nor-100",
    "tema": "normas",
    "enunciado": "Texto de la pregunta",
    "opciones": ["Opción A", "Opción B", "Opción C"],
    "correcta": 1,
    "explicacion": "Por qué la B es la correcta.",
    "imagen": null
  }
]
```

- `tema`: `normas`, `senalizacion`, `seguridad`, `tecnicas`, `pasajero_carga`, `mecanica`, `documentacion`, `riesgos`.
- `correcta`: 0, 1 o 2.
- `imagen`: `null`, el nombre de una imagen de la app (p. ej. `"senal_r2"`) o una imagen incrustada `"data:image/png;base64,..."`.

## Estructura

```
MotoTestA2/
├── App/           Punto de entrada y rutas
├── Modelos/       Pregunta, Tema, ModoTest y modelos SwiftData
├── Servicios/     Banco de preguntas, generador de tests, fallos, háptica…
├── VistasModelo/  Lógica de práctica, simulacro y estadísticas
├── Vistas/        Pantallas
└── Recursos/      preguntas.json e imágenes
```
