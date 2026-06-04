# Strata — Contexto del Proyecto

## El juego

**Strata** es un puzzle-platformer que tiene como mecánica central es la manipulación de dimensiones. El jugador puede colapsar el mundo desde distintas perspectivas para conectar plataformas separadas, atravesar obstáculos y alcanzar zonas inaccesibles en la otra dimensión.

La referencia mecánica directa es *Crush* (Zoë Mode, 2007): la solución de cada puzzle depende de **cuándo y desde qué ángulo** se aplasta el mundo.

La narrativa y el lore están pendientes de definición.

---

## Estructura de carpetas

```
strata-project/
├── assets/
│   └── sprites/
│
├── autoloads/
│   ├── audio_manager.gd
│   ├── audio_manager.tscn
│   ├── debug.gd
│   ├── event_bus.gd
│   ├── game_manager.gd
│   ├── level_manager.gd
│   └── level_manager.tscn
│
├── components/
│   └── hitbox_component.gd
│
├── gameplay/
│   └── collectible.gd
│
├── scenes/
│   ├── levels/
│   │   ├── background.tscn
│   │   ├── level_1.tscn
│   │   └── level_2.tscn
│   │
│   ├── objects/
│   │   ├── BlockMovable.tscn
│   │   ├── block_movable.gd
│   │   ├── Button.tscn
│   │   └── button.gd
│   │
│   └── player/
│       ├── camera_handler.gd
│       ├── camera_pivot.gd
│       ├── player.gd
│       └── player.tscn
│
├── ui/
│   ├── MainMenu.tscn
│   ├── main_menu.gd
│   ├── PauseMenu.tscn
│   ├── pause_menu.gd
│   ├── credits.tscn
│   ├── credits.gd
│   ├── hud.tscn
│   └── theme.tres
│
├── default_bus_layout.tres
├── icon.svg
├── project.godot
└── README.md
```

---

## Convención de nombres

| Tipo | Convención | Ejemplo |
|---|---|---|
| Escenas | PascalCase | `Player.tscn` |
| Scripts | snake_case | `player_movement.gd` |
| Carpetas | lowercase | `player/`, `scenes/` |

---

## División de trabajo #1

**Persona 1 — Player** `feature/player`
Trabaja exclusivamente en `player/`.
- Movimiento, salto, colisiones
- Estado del personaje (vivo, muerto, en transición)
- Cómo el jugador reacciona al cambio de dimensión

**Persona 2 — Dimension System** `feature/dimension-system`
Trabaja exclusivamente en `scenes/dimension/`.
- Colapso de geometría según perspectiva/ángulo
- Propiedades de bloques según dimensión (sólido, atravesable, letal)
- Estado global del mundo (2D / 3D / en transición)
- Condición de victoria del nivel

**Persona 3 — Level Objects** `feature/level-objects`
Trabaja exclusivamente en `scenes/objects/` y `gameplay/`.
- Construcción de niveles concretos
- Bloques movibles, botones, triggers
- Nunca toca `scenes/dimension/` directamente — solo escucha sus señales

> **Regla de oro:** cada persona toca solo su carpeta. Los conflictos de merge son casi imposibles si se respeta esto.

---

## Zonas compartidas (coordinar antes de tocar)

| Archivo/carpeta | Por qué es compartido |
|---|---|
| `autoloads/` | Global, todos dependen de esto |
| `components/` | Reutilizado por player, objects y enemies |
| `scenes/world/World.tscn` | Escena raíz que instancia todo |
| `ui/` | Cualquiera puede necesitar ajustar la UI |
| `project.godot` | Autoloads, inputs, configuración global |

Si necesitas tocar alguno de estos, avísale al equipo antes.

---

## Comunicación entre sistemas (EventBus)

Los sistemas **no se importan entre sí**. Se comunican solo a través de señales en `autoloads/EventBus.gd`:

```gdscript
# autoloads/EventBus.gd
extends Node

signal dimension_changed(new_dimension: String)  # "2D" | "3D"
signal player_died()
signal level_completed()
signal object_interacted(object_id: String)
```

**Ejemplo de uso:**
```gdscript
# Persona 2 emite cuando el jugador aplasta
EventBus.dimension_changed.emit("2D")

# Persona 1 escucha y ajusta colisiones del player
EventBus.dimension_changed.connect(_on_dimension_changed)

# Persona 3 escucha y cambia propiedades de objetos
EventBus.dimension_changed.connect(_on_dimension_changed)
```

---

## Audio

El proyecto usa dos buses de audio separados. Configurarlos en `Project → Audio`:

| Bus | Uso |
|---|---|
| `Music` | Música de fondo |
| `SFX` | Efectos de sonido |

```gdscript
AudioManager.play_music()
AudioManager.play_sfx(sfx_resource)
```

---

## Flujo de Git

```
main          ← siempre jugable
develop       ← integración continua
feature/X     ← trabajo individual
```

1. Crear branch desde `develop`: `git checkout -b feature/mi-feature develop`
2. Trabajar en tu carpeta
3. Pull Request a `develop`
4. Cuando `develop` está estable → merge a `main`

**Nunca pushear directo a `main` ni a `develop`.**

---

## Autoloads registrados

Registrar en `Project → Project Settings → Autoload`:

| Nombre | Archivo |
|---|---|
| `EventBus` | `autoloads/EventBus.gd` |
| `GameManager` | `autoloads/GameManager.gd` |
| `LevelManager` | `autoloads/LevelManager.gd` |
| `AudioManager` | `autoloads/audio_manager.tscn` |
| `Debug` | `autoloads/debug.gd` |

---

## Checklist del prototipo mínimo

- [ ] El jugador se mueve y salta en un nivel básico
- [ ] Se puede cambiar de dimensión (crush) desde al menos una perspectiva
- [ ] Al menos un objeto reacciona al cambio de dimensión
- [ ] Existe una condición de victoria (`Goal.tscn`)
- [x] Hay un menú principal y un menú de pausa
- [x] Hola
-
-
