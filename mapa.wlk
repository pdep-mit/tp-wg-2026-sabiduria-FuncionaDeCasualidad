import wollok.game.*

// Esqueleto de dominio: los cuerpos con TODO quedan para el equipo.
// Las clases visuales traducen columna/fila a x/y de wollok.game.
class Mapa {
  const property filas
  const property columnas
  const property casilleros = []
  const property zombies = []

  method crearCasilleros() {
    casilleros.clear()
    (0 .. filas - 1).forEach({ f =>
      (0 .. columnas - 1).forEach({ c =>
        casilleros.add(new Casillero(fila = f, columna = c))
      })
    })
  }

  method casilleroEn(fila, columna) {
    return casilleros.findOrElse(
      { c => c.fila() == fila and c.columna() == columna },
      { null }
    )
  }

  method contiene(fila, columna) {
    return fila.between(0, filas - 1) and columna.between(0, columnas - 1)
  }

  method puedeColocarDefensaEn(fila, columna) {
    const casillero = self.casilleroEn(fila, columna)
    return self.contiene(fila, columna) and casillero != null and not casillero.estaOcupado()
  }

  method colocarDefensa(defensa, fila, columna) {
    if (!self.puedeColocarDefensaEn(fila, columna)) {
      self.error("No se puede colocar la defensa en la posición (" + columna + ", " + fila + ")")
    }
    self.casilleroEn(fila, columna).colocarDefensa(defensa)
  }

  method quitarDefensa(defensa) {
    const casillero = casilleros.findOrElse({ c => c.defensa() == defensa }, { null })
    if (casillero != null) {
      casillero.quitarDefensa()
    }
  }

  method defensas() {
    return casilleros.filter({ c => c.estaOcupado() }).map({ c => c.defensa() })
  }

  method agregarZombie(zombie) {
    zombies.add(zombie)
  }

  method quitarZombie(zombie) {
    zombies.remove(zombie)
  }

  method zombiesEnLinea(fila) {
    return zombies.filter({ zombie => zombie.position().y() == fila })
  }

  method zombiesEnRango(fila, columna, alcance) {
    return self.zombiesEnLinea(fila).filter({ zombie =>
      zombie.position().x() >= columna and zombie.position().x() <= (columna + alcance)
    })
  }

  method defensaEn(fila, columna) {
    if (!self.contiene(fila, columna)) {
      return null
    }
    const casillero = self.casilleroEn(fila, columna)
    if (casillero == null) {
      return null
    }
    return casillero.defensa()
  }

  method algunZombieLlegoALaCasa() {
    return zombies.any({ zombie => zombie.llegoALaCasa() })
  }
}

class Casillero {
  const property imagen = "tile_centro.png"
  const property fila
  const property columna
  var property defensa = null

  method position() = game.at(columna, fila)
  method image() = imagen

  method estaOcupado() = defensa != null

  method colocarDefensa(unaDefensa) {
    if (self.estaOcupado()) {
      self.error("El casillero ya está ocupado.")
    }
    defensa = unaDefensa
    unaDefensa.position(self.position())
  }

  method quitarDefensa() {
    defensa = null
  }
}
