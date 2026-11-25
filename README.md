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

* **Ganás** si sobrevivís a las **3 oleadas** y eliminás a todos los zombies de la oleada final.
* **Perdés** si algún zombie logra llegar a la casa.

La primera oleada trae 6 zombies (4 comunes y 2 albañiles) y las otras dos, 20 cada una. Los larga cada vez más seguido: uno por segundo en la primera, cada 0,15 s en la segunda y cada 0,08 s en la final. Al empezar cada oleada se anuncia en pantalla y al terminar te da **50 pesos** de bonus.

La barra superior muestra tus pesos, la velocidad activa (`1x` o `2x`), el estado de la partida y la defensa seleccionada (junto a si está lista o en recarga). Para jugar de nuevo cuando termina la partida, reiniciá el programa.

## Controles

* **`1` / `2` / `3`**: seleccionar **Vendecursos**, **Verdulero** o **Panadero**.
* **Clic en el panel superior**: también te deja elegir la defensa haciendo clic en su retrato.
* **Flechas (`↑` `↓` `←` `→`)**: mover el cursor por el tablero (si el casillero es válido, ves una vista previa).
* **`Enter`**: colocar la defensa seleccionada en la casilla del cursor.
* **`R`**: alternar entre velocidad normal (`1x`) y doble (`2x`).

> Para colocar una defensa necesitás que te alcancen los pesos, que la recarga de ese tipo haya terminado, que la casilla esté libre (sin zombies ni otra defensa) y que no sea la última columna, reservada para la aparición de los zombies.

## Economía y defensas

Arrancás la partida con **200 pesos** y además recibís **25 pesos** automáticamente cada segundo.

| Defensa | Costo | Vida | Recarga | Qué hace |
| :--- | :---: | :---: | :---: | :--- |
| **Vendecursos** | 50 pesos | 100 | 0,5 s | Genera 25 pesos por segundo. |
| **Verdulero** | 100 pesos | 50 | 0,5 s | Lanza un tomate (20 de daño) cada 0,2 s al zombie más cercano de su fila. |
| **Panadero** | 50 pesos | 500 | 2 s | No ataca, pero aguanta muchos golpes (recibe un 30% menos de daño). |

## Zombies

| Zombie | Vida | Particularidad |
| :--- | :---: | :--- |
| **Común** | 100 | Avanza una casilla cada 0,75 s de derecha a izquierda y muerde a la defensa que tenga delante. |
| **Albañil** | 300 | Mucho más resistente, pero más lento: una casilla por segundo. |
| **Motoquero** | 100 | En moto cruza el mapa en poco más de 1 segundo y es **inmune al daño**; al toparse con una defensa se baja y desde ahí camina y recibe daño como un común. |
| **Inspector** | 100 | Mientras siga vivo en el tablero, **bloquea a todos los Vendecursos** para que no generen pesos. |

## Verificación

* `wollok test -p ./`: corre los tests del proyecto.
* `wollok lint -p ./`: validación estática del código.
