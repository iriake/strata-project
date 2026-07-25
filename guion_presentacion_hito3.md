# Guión de Presentación Final - Hito 3: Strata

Este documento contiene la estructura y el guión detallado para el video de presentación del examen (Hito 3) del videojuego **Strata**. El guión está diseñado para durar aproximadamente **6 a 7 minutos** en total y requiere la participación de todo el equipo (ejemplo estructurado para 3 integrantes: **Integrante A, B y C**).

---

## 🎬 Estructura del Video (Timeline)

| Tiempo | Sección | Orador | Apoyo Visual (Pantalla) |
| :--- | :--- | :--- | :--- |
| **0:00 - 1:00** | Introducción y Concepto | Integrante A | Menú Principal $\rightarrow$ Gameplay rápido del personaje en 3D. |
| **1:00 - 2:15** | Mecánica Innovadora y Técnica | Integrante B | Gameplay mostrando la transición 3D a 2D y la cámara. |
| **2:15 - 3:30** | Flujo del Juego e Interfaces | Integrante A / B | Flujo desde el Inicio $\rightarrow$ Menú de Pausa $\rightarrow$ Menú Principal. |
| **3:30 - 4:45** | Tutorial y Aprendizaje | Integrante C | Gameplay del nivel de Tutorial explicando los controles y mecánicas. |
| **4:45 - 6:00** | Diseño de Puzzles (Level 1 y 2) | Integrante C | Demostración de las soluciones de puzzles en el Nivel 2. |
| **6:00 - 7:00** | Conclusión y Créditos | Integrante A / B / C | Pantalla de Créditos $\rightarrow$ Llamado a la acción en Itch.io. |

---

## 📝 Guión Detallado (Locución)

### 🎙️ Parte 1: Introducción y Concepto del Juego (0:00 - 1:00)
**Visual en pantalla:** Se muestra el Menú Principal, limpio y estilizado. El cursor presiona "Jugar" y el juego carga instantáneamente, mostrando al personaje principal en un entorno 3D de estética industrial/cyberpunk.

*   **Integrante A:**
    > "Hola a todos. Bienvenidos a la presentación final de **Strata**, un videojuego de puzzles y plataformas en tres dimensiones que desafía la percepción espacial del jugador. 
    > 
    > En la mayoría de los plataformas, la perspectiva es fija. Sin embargo, en **Strata** el mundo tridimensional no es más que una sugerencia. Nuestro protagonista, un pequeño robot, tiene la habilidad de colapsar la profundidad de su entorno y proyectar el mundo en dos dimensiones.
    > 
    > La premisa principal es simple: existen obstáculos, brechas y alturas que son insuperables en un espacio 3D. Pero al cambiar la dimensión, las plataformas se alinean, los muros se sortean y las distancias cambian, revelando caminos que antes eran completamente invisibles."

---

### 🎙️ Parte 2: La Mecánica Innovadora y su Tecnología (1:00 - 2:15)
**Visual en pantalla:** El jugador camina en 3D, salta, y de pronto presiona la tecla de cambio. La cámara rota suavemente y se aplana en un plano 2D lateral. Se resalta en primer plano el efecto de la cámara y el cambio de proyección.

*   **Integrante B:**
    > "Para lograr este comportamiento, implementamos un sistema dinámico de proyección y alineación matemática. Cuando el jugador decide cambiar a 2D, el juego detecta el ángulo actual de la cámara y bloquea el eje correspondiente (ya sea X, Y o Z). 
    > 
    > Al mismo tiempo, todas las plataformas del grupo `change_geometry` colapsan su posición y escala física sobre el plano del jugador. Esto no es solo un efecto visual; las colisiones físicas en 3D se aplanan en tiempo real, permitiendo que el jugador camine sobre proyecciones 2D.
    > 
    > Uno de los mayores desafíos técnicos fue el comportamiento de la cámara. Para la vista lateral, la cámara pasa a proyección **Ortográfica** para dar la sensación pura de un juego 2D tradicional. Sin embargo, descubrimos que en la **vista cenital (top-down)**, la proyección ortogonal eliminaba la profundidad del cielo radial. Para solucionarlo, en la vista superior mantuvimos la proyección en **Perspectiva**, logrando que el panorama urbano en 3D se proyecte radialmente hacia los bordes del escenario, simulando una caída libre al vacío y manteniendo una rica fidelidad visual."

---

### 🎙️ Parte 3: Flujo de Juego, Menús e Interfaz (2:15 - 3:30)
**Visual en pantalla:** Se muestra el funcionamiento del HUD en la parte superior izquierda (marcador de engranajes). Luego, a mitad del juego, el jugador presiona `Esc` y se despliega el Menú de Pausa. Se ve cómo el fondo se oscurece completamente bloqueando la vista de las plataformas.

*   **Integrante A:**
    > "Al ser este el examen final del curso, nos enfocamos en que **Strata** sea una experiencia de juego completa y pulida, libre de placeholders y con un flujo natural. 
    > 
    > Diseñamos un flujo que va desde un Menú Principal interactivo, pasando por un HUD dinámico en tiempo real que registra la recolección de los engranajes esparcidos por el mapa. Los coleccionables cuentan con física de flotación y rotación, y emiten efectos de sonido que se integran a la música de fondo del juego."

*   **Integrante B:**
    > "También optimizamos el menú de pausa. Anteriormente, al pausar el juego en modo 2D, las plataformas 3D seguían viéndose por detrás de la interfaz. Lo solucionamos implementando un fondo opaco que aísla visualmente el estado del nivel y permite al usuario reiniciar, continuar o salir al menú principal de forma limpia. 
    > 
    > Adicionalmente, el juego cuenta con un gestor global de audio (`AudioManager`) implementado como un Autoload persistente. Esto permite que la música de fondo, en este caso el tema *Exploding Sun.mp3*, se reproduzca ininterrumpidamente desde que abres el menú hasta que terminan los créditos, sin pausarse al entrar al menú de pausa."

---

### 🎙️ Parte 4: Curva de Aprendizaje y el Tutorial (3:30 - 4:45)
**Visual en pantalla:** Gameplay directo del nivel de Tutorial. El jugador lee las instrucciones en pantalla, realiza saltos básicos en 3D, y luego usa el cambio de dimensión para cruzar el primer abismo.

*   **Integrante C:**
    > "Para introducir al jugador a estas mecánicas tan abstractas de forma amigable, diseñamos un nivel de **Tutorial**. Aquí, el jugador aprende primero a moverse en el espacio 3D convencional. 
    > 
    > Pronto se encuentra con un abismo imposible de saltar. El tutorial le enseña a rotar la cámara y presionar el botón de dimensión. Al hacerlo, el abismo tridimensional se reduce a una línea recta horizontal en 2D, permitiéndole cruzar con facilidad. 
    > 
    > De esta manera, el jugador asimila de forma orgánica cómo el cambio de perspectiva de la cámara altera la física y las plataformas del nivel, preparándolo para los desafíos más complejos."

---

### 🎙️ Parte 5: Diseño de Puzzles Avanzado - Nivel 2 (4:45 - 6:00)
**Visual en pantalla:** Gameplay en tiempo real del Nivel 2. Se muestra al jugador resolviendo los tres puzzles diseñados:
1. Usar la vista lateral 2D (bloqueo Z) para alinear una plataforma lejana.
2. Usar la vista cenital (bloqueo Y) para rodear el gran muro vertical.
3. Usar la vista frontal 2D (bloqueo X) para subir por las plataformas que se alinean.

*   **Integrante C:**
    > "En el **Nivel 2**, llevamos la mecánica al límite de su diseño de puzzles, combinando los tres ejes de bloqueo. 
    > 
    > Primero, el jugador debe alcanzar un engranaje usando la vista lateral, donde una plataforma flotante en el fondo se alinea como puente. 
    > 
    > Luego, se encuentra con una muralla gigante. En 3D es infranqueable, pero al pasar a la vista superior o cenital en 2D, el jugador puede ignorar la altura y caminar alrededor de la pared sobre el plano horizontal. 
    > 
    > Por último, implementamos un puzzle que requiere la vista frontal (bloqueando el eje X). Al aplanar el mundo de frente, varias plataformas dispersas a los lados se alinean verticalmente en la pantalla, creando una escalera funcional que le permite escalar hacia la meta y recolectar el último engranaje."

---

### 🎙️ Parte 6: Pantalla de Créditos y Despedida (6:00 - 7:00)
**Visual en pantalla:** El jugador recoge el último engranaje, el nivel se completa y la pantalla transiciona suavemente a la escena de Créditos, donde se desplazan los nombres de los creadores y los agradecimientos por los assets de audio y modelado utilizados.

*   **Integrante A:**
    > "Una vez recolectados todos los engranajes de los niveles, el juego culmina en esta pantalla de créditos final, cerrando el ciclo completo del juego."

*   **Integrante B:**
    > "El juego ya se encuentra disponible para su descarga en la plataforma **Itch.io**. Hemos verificado que el ejecutable es público, auto-contenido y que funciona correctamente en diversos ordenadores sin dependencias externas."

*   **Integrante C:**
    > "Agradecemos profundamente su tiempo y esperamos que disfruten de la experiencia mental y espacial que ofrece **Strata**. ¡Muchas gracias!"
