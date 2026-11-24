# Conurbano vs. Zombies

**Grupo:** FuncionaDeCasualidad

**Integrantes:**
- Pablo Manevy
- Matías Orlando
- Camila Echavarria
- Thibes Mateo
- Luciano Aieta

## Cómo ejecutarlo

Con Wollok instalado, ejecutá desde la raíz del proyecto:

```powershell
wollok run juego.ConurbanoVsZombies -p ./
```

Luego abrír `http://localhost:3000` en tu navegador.

## Objetivo

Defendé tu casa (la primera columna de la izquierda) evitando que los zombies crucen el mapa de 5 filas × 9 columnas.

* **Ganás** si sobrevivís a las **4 oleadas** y eliminás a todos los zombies de la oleada final.
* **Perdés** si algún zombie logra llegar a la casa.

La barra superior muestra tus pesos, la velocidad activa (`1x` o `2x`), el estado de la partida y la defensa seleccionada (junto a si está lista o en recarga). Para jugar de nuevo cuando termina la partida, reiniciá el programa.

## Controles

* **`1` / `2` / `3`**: seleccionar **Vendecursos**, **Verdulero** o **Panadero**.
* **Clic en el panel superior**: también te deja elegir la defensa haciendo clic en su retrato.
* **Flechas (`↑` `↓` `←` `→`)**: mover el cursor por el tablero (si el casillero es válido, ves una vista previa).
* **`Enter`**: colocar la defensa seleccionada en la casilla del cursor.
* **`R`**: alternar entre velocidad normal (`1x`) y doble (`2x`).

> Para colocar una defensa necesitás que te alcancen los pesos, que la recarga de ese tipo haya terminado, que la casilla esté libre (sin zombies ni otra defensa) y que no sea la última columna, reservada para la aparición de los zombies.

## Economía y defensas

Arrancás la partida con **100 pesos** y además recibís **25 pesos** automáticamente cada 2 segundos.

| Defensa | Costo | Vida | Recarga | Qué hace |
| :--- | :---: | :---: | :---: | :--- |
| **Vendecursos** | 50 pesos | 100 | 1 s | Genera 25 pesos periódicamente. |
| **Verdulero** | 100 pesos | 50 | 1 s | Lanza tomates (20 de daño) al zombie más cercano de su fila. |
| **Panadero** | 50 pesos | 500 | 5 s | No ataca, pero aguanta muchos golpes (recibe un 30% menos de daño). |

## Zombies

| Zombie | Vida | Particularidad |
| :--- | :---: | :--- |
| **Común** | 100 | Avanza de derecha a izquierda y muerde a la defensa que tenga delante. |
| **Albañil** | 300 | Mucho más resistente. |
| **Motoquero** | 100 | Es **inmune al daño** mientras anda en moto; al toparse con una defensa se baja y recién ahí recibe daño. |
| **Inspector** | 100 | Mientras siga vivo en el tablero, **bloquea a todos los Vendecursos** para que no generen pesos. |

## Verificación

* `wollok test -p ./`: corre los tests del proyecto.
* `wollok lint -p ./`: validación estática del código.
