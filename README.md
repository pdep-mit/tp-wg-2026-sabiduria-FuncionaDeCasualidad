# Conurbano vs. Zombies

**Grupo:** FuncionaDeCasualidad

**Integrantes:**
- Nombre y Apellido
- Nombre y Apellido
- Nombre y Apellido
- Nombre y Apellido
- Nombre y Apellido

## Consignas

Todo lo que necesitan saber está explicado en [este documento](https://docs.google.com/document/d/1KoB12RIZk_xPhmnOJ-EfLIPNwkETD_EaYMp2srDu9QY/edit?tab=t.0#heading=h.wnm2lu4cls8j). Para todo lo demás, aseguren prestar atención a los comunicados por Discord.

Revisen los archivos de base y cambien lo que quieran para ajustarlo a sus necesidades. Lo primero que deberían hacer es actualizar 

Recuerden que para cada checkpoint hay [expectativas mínimas](https://docs.google.com/document/d/1KoB12RIZk_xPhmnOJ-EfLIPNwkETD_EaYMp2srDu9QY/edit?tab=t.0#heading=h.56t0qdv908v3) respecto a los conceptos aplicados. Procuren:
- Validar su idea con el equipo docente que corresponda por su canal de Discord
- Para cada checkpoint, asegurar que implementaron lo necesario para esa instancia, y crear un **tag** en el repositorio para facilitar la comparación entre versiones final e intermedias.
- Para la demo final, crear un nuevo tag **demo** y actualizar este README con todo lo necesario.

# Cómo jugar

Juego de defensa por líneas desarrollado en Wollok. El checkpoint 1 integra el
mapa de 5 filas × 9 columnas, las tres defensas, zombies comunes, pesos,
recargas y derrota. Hay 45 casilleros jugables y una franja superior de estado. Ver la
[explicación del dominio](explicaciones.md).
El [diagrama de clases completo](DIAGRAMA_CLASES.md) muestra la estructura actual.

Con Wollok instalado, ejecutar `wollok run juego.ConurbanoVsZombies -p ./`.
Después de cambiar código o imágenes, detener esa ejecución con `Ctrl+C`,
volver a ejecutar el comando y recargar la pestaña del juego. Wollok no
actualiza una partida que ya estaba abierta.

## Objetivo

Evitá que los zombies, que avanzan de derecha a izquierda, alcancen la columna 0.
El Vendecursos genera ingresos, el Verdulero ataca al zombie vivo más cercano
delante suyo en su fila y el Panadero absorbe mordiscos. Los zombies se detienen
en la casilla a la derecha de una defensa para atacarla. Al llegar un zombie
a la casa, aparece el mensaje de derrota y la partida se detiene. Para volver
a jugar, ejecutar nuevamente el programa.

## Controles

- `1`: seleccionar Vendecursos (50 pesos).
- `2`: seleccionar Verdulero (100 pesos).
- `3`: seleccionar Panadero (50 pesos).
- También se puede elegir una defensa haciendo clic en su retrato del panel superior.
- Flechas: mover el cursor, que comienza en la casilla `(0, 0)`.
- La defensa elegida aparece semitransparente en el cursor si la casilla permite colocarla.
- `Enter`: colocar la defensa seleccionada en la casilla del cursor.
- `R`: alternar entre velocidad normal y 2x; el panel superior muestra el modo activo.

En 2x avanzan el doble de rápido los zombies, proyectiles, recargas, ataques y
la generación de pesos.

La colocación requiere una casilla libre, sin zombies y fuera de la última
columna, reservada para su aparición, además de pesos suficientes. Si no se
puede colocar, no se descuenta dinero. La selección se conserva para colocar más
defensas. La recarga es independiente por tipo: 60 ticks (1 segundo) para
Vendecursos y Verdulero, 300 ticks (5 segundos) para Panadero. La franja
superior muestra saldo, estado de la partida y selección con su recarga.

## Economía y tiempos

El juego actualiza 60 veces por segundo. Se empieza con 100 pesos y se reciben
25 cada 120 ticks (2 segundos). Cada Vendecursos inicia una venta cada 120 ticks
y agrega 25 pesos al llegar al segundo cuadro de su animación. El Verdulero
inicia un ataque cada 30 ticks (0,5 segundos), lanza el proyectil en el tercer
cuadro y hace 20 de daño cuando impacta. El Panadero tiene 500 de vida y recibe
un 30% menos de daño.
Aparece un zombie común cada 300 ticks (5 segundos) en una fila aleatoria.
Cada zombie avanza una casilla cada 180 ticks (3 segundos); al alcanzar una
defensa, le hace 10 de daño cada 30 ticks (0,5 segundos).

## Verificación

- `wollok test -p ./`: tests de dominio, controles e integración.
- `wollok lint -p ./`: validación estática.

Carnicero, Aguatero, fusiones, efectos temporales y zombies especiales quedan
para etapas posteriores.

# Explicaciones

Las explicaciones teóricas y diagramas van a encontrarse en [explicaciones.md](explicaciones.md) a partir del Checkpoint #2.
