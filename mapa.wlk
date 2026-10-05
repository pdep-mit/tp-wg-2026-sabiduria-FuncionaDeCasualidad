import wollok.game.*

// Esqueleto de dominio: los cuerpos con TODO quedan para el equipo.
// Las clases visuales traducen columna/fila a x/y de wollok.game.
class Mapa {
  const property filas
  const property columnas
  const property casilleros = []
  const property zombies = []

  method crearCasilleros() { /* TODO: crear la grilla. */ }
  method casilleroEn(fila, columna) { /* TODO: devolver el casillero. */ }
  method contiene(fila, columna) { /* TODO: indicar si está dentro del mapa. */ }
  method puedeColocarDefensaEn(fila, columna) { /* TODO: validar límites y ocupación. */ }
  method colocarDefensa(defensa, fila, columna) { /* TODO: ocupar una única casilla. */ }
  method quitarDefensa(defensa) { /* TODO: liberar su casilla. */ }
  method defensas() { /* TODO: devolver las defensas de los casilleros. */ }
  method agregarZombie(zombie) { /* TODO: incorporar un enemigo. */ }
  method quitarZombie(zombie) { /* TODO: retirar un enemigo muerto. */ }
  method zombiesEnLinea(fila) {
    return zombies.filter({ zombie => zombie.position().y() == fila })
  }
  method zombiesEnRango(fila, columna, alcance) { /* TODO: buscar objetivos. */ }
  method defensaEn(fila, columna) { /* TODO: devolver la defensa o null. */ }
  method algunZombieLlegoALaCasa() { /* TODO: consultar el límite de llegada. */ }
}

class Casillero {
  const property imagen = "tile_centro.png"
  const property fila
  const property columna
  var property defensa = null

  method position() = game.at(columna, fila)
  method image() = imagen

  method estaOcupado() { /* TODO: consultar si contiene una defensa. */ }
  method colocarDefensa(unaDefensa) { /* TODO: rechazar una segunda defensa. */ }
  method quitarDefensa() { /* TODO: liberar el casillero. */ }
}
