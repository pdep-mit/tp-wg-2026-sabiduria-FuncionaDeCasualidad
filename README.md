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

Con Wollok instalado, ejecutar `wollok run juego.ConurbanoVsZombies -p ./`.

## Objetivo

Evitá que los zombies, que avanzan de derecha a izquierda, alcancen la columna 1.
El Vendecursos genera ingresos, el Verdulero ataca al zombie vivo más cercano
delante suyo en su fila y el Panadero absorbe mordiscos. Conviene colocar
defensas desde la columna 2 hacia la derecha. Al llegar un zombie a la casa,
aparece el mensaje de derrota y la partida se detiene. Para volver a jugar,
ejecutar nuevamente el programa.

## Controles

- `1`: seleccionar Vendecursos (25 pesos).
- `2`: seleccionar Verdulero (10 pesos).
- `3`: seleccionar Panadero (5 pesos).
- Flechas: mover el cursor amarillo `+`, que comienza en la casilla `(0, 0)`.
- `Enter`: colocar la defensa seleccionada en la casilla del cursor.

La colocación requiere una casilla libre y pesos suficientes. Si no se puede
colocar, no se descuenta dinero. La selección se conserva para colocar más
defensas. La recarga es independiente por tipo: 5 ticks para Vendecursos y
Verdulero, 30 para Panadero. La franja superior muestra saldo, estado de la
partida y selección con su estado de recarga.

## Economía y tiempos

Cada tick dura 100 ms. Se empieza con 100 pesos y se reciben 25 cada 50 ticks.
Cada Vendecursos agrega 25 pesos cada 10 ticks. El Verdulero hace 20 de daño
cada 10 ticks; el Panadero tiene 300 de vida. Aparecen zombies comunes cada
30 ticks en una fila aleatoria, además del zombie inicial en la fila central.
El zombie avanza una casilla entera cada 30 ticks (3 segundos), se detiene
frente a una defensa y continúa cuando esta es destruida.

## Verificación

- `wollok test -p ./`: tests de dominio, controles e integración.
- `wollok lint -p ./`: validación estática.

Carnicero, Aguatero, fusiones, efectos temporales y zombies especiales quedan
para etapas posteriores.

# Explicaciones

Las explicaciones teóricas y diagramas van a encontrarse en [explicaciones.md](explicaciones.md) a partir del Checkpoint #2.
