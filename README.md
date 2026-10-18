# Personaje 3D - base de proyecto Godot 4.x

Proyecto académico inicial para practicar escenario, control de personaje, cámara, colisiones y una máquina de estados finitos (FSM).

> **Estado del proyecto:** es una base funcional propuesta, no una entrega final verificada dentro del editor Godot en esta sesión. El personaje que aparece es una figura provisional hecha con primitivas. Debes abrir el proyecto en Godot 4.x, probarlo en tu computadora e incorporar el modelo IA real y tus capturas antes de entregarlo.

## Requisitos

- Godot Engine 4.x.
- No se requieren complementos externos.
- Renderer configurado en Compatibility para mantenerlo sencillo.

## Abrir y ejecutar

1. Descomprime la carpeta `Godot_3D_Inicial`.
2. Abre Godot y selecciona **Importar**.
3. Busca el archivo `project.godot` dentro de esta carpeta.
4. Abre el proyecto y presiona **F6** para probar `Main.tscn` o **F5** para iniciar la escena principal.
5. Si Godot pregunta por importar recursos, permite que termine.

## Controles

- **W A S D:** moverse relativo a la orientación horizontal de la cámara.
- **Barra espaciadora:** saltar cuando el personaje está en el suelo.
- **Mouse:** girar la cámara.
- **Esc:** liberar/recapturar el cursor.

## Estructura

```text
Godot_3D_Inicial/
├── project.godot
├── scenes/
│   ├── Main.tscn        # escena principal que instancia el nivel y el personaje
│   ├── Level.tscn       # suelo, obstáculos, cielo procedural y luz direccional
│   └── Character.tscn   # CharacterBody3D, colisión, visual provisional, cámara y HUD
├── scripts/
│   └── player.gd        # movimiento, gravedad, salto, cámara y FSM
├── Prompts/
│   ├── prompt_personaje.txt
│   └── bitacora_y_comparacion.md
├── assets/modelo_IA/    # coloca aquí el modelo exportado y sus texturas
└── Documentacion/
    └── informe_base.pdf # borrador de 5 páginas por completar
```

## Separación de responsabilidades

- `CharacterBody3D`: colisiones y posición física.
- `player.gd` en `_physics_process(delta)`: controles, velocidad horizontal, gravedad, salto y `move_and_slide()`.
- `player.gd` en `_process(delta)`: giro suave de la representación visual.
- `CameraPivot` + `SpringArm3D` + `Camera3D`: orientación y seguimiento de la cámara; la máscara del brazo evita detectar la capa del propio jugador.
- `VisualRoot`: contiene la figura provisional. Al importar un modelo generado, conserva `CharacterBody3D`, `CollisionShape3D`, scripts y cámara; reemplaza únicamente el contenido visual dentro de `VisualRoot`.
- FSM: `IDLE`, `WALK`, `JUMP`; el estado aparece en pantalla y se imprime cuando cambia.

## Nota sobre `delta`

La gravedad cambia la velocidad vertical, por eso se calcula `velocity.y -= gravity * delta`. La velocidad horizontal se expresa en unidades por segundo y se asigna directamente. `move_and_slide()` usa el paso físico internamente, así que no se debe hacer `velocity * delta` antes de llamarlo. En `_process(delta)`, `delta` se usa para que el giro visual sea consistente entre distintas tasas de fotogramas.

## Pendientes para la entrega real

- Probar movimiento, salto, colisión con todos los obstáculos y giros de cámara junto a la pared.
- Generar y exportar el personaje con Tripo/Meshy (o usar un recurso de práctica autorizado si el acceso falla) y anotar su procedencia real.
- Actualizar triángulos, materiales, texturas, escala y ajustes según la exportación real; no inventar estadísticas.
- Añadir tres capturas propias de las pruebas al PDF.
- Agregar enlaces funcionales al repositorio completo y a un video propio de 1-2 minutos.
- Completar los campos de fecha, herramienta, ajustes y comparación de la carpeta `Prompts`.

## Documentación oficial consultada

- CharacterBody3D: https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html
- SpringArm3D: https://docs.godotengine.org/en/stable/classes/class_springarm3d.html
- ProceduralSky: https://docs.godotengine.org/en/stable/classes/class_proceduralsky.html
