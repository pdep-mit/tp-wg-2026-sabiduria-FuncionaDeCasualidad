import wollok.game.*

// Las clases visuales traducen columna/fila a x/y de wollok.game.
class Mapa {
  const property filas
  const property columnas
  const property casilleros = []
  const property zombies = []
  var defensasActivas = []

  method crearCasilleros() {
    casilleros.clear()
    // Los casilleros comparten esta lista para sincronizar también cambios directos.
    // Reemplazarla aísla a los casilleros de la grilla anterior.
    defensasActivas = []
    (0 .. filas - 1).forEach({ f =>
      (0 .. columnas - 1).forEach({ c =>
        casilleros.add(new Casillero(fila = f, columna = c, defensasActivas = defensasActivas))
      })
    })
  }

  method casilleroEn(fila, columna) {
    if (!self.contiene(fila, columna)) { return null }
    const indice = fila * columnas + columna
    return if (indice < casilleros.size()) casilleros.get(indice) else null
  }

  method contiene(fila, columna) {
    return fila.between(0, filas - 1) and columna.between(0, columnas - 1)
      and fila == fila.roundDown() and columna == columna.roundDown()
  }

  method puedeColocarDefensaEn(fila, columna) {
    const casillero = self.casilleroEn(fila, columna)
    return self.contiene(fila, columna) and casillero != null and not casillero.estaOcupado()
  }

  method colocarDefensa(defensa, fila, columna) {
    if (defensasActivas.contains(defensa)) {
      self.error("La defensa ya está colocada en el mapa.")
    }
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
    // Devolver una copia protege la colección y permite retirar durante un recorrido.
    return defensasActivas.copy()
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
  var defensa = null
  const defensasActivas = []

  method defensa() = defensa

  method position() = game.at(columna, fila)
  method image() = imagen

  method estaOcupado() = defensa != null

  method colocarDefensa(unaDefensa) {
    if (self.estaOcupado() or defensasActivas.contains(unaDefensa)) {
      self.error("El casillero ya está ocupado.")
    }
    defensa = unaDefensa
    unaDefensa.position(self.position())
    defensasActivas.add(unaDefensa)
  }

  method quitarDefensa() {
    if (defensa != null) {
      defensasActivas.remove(defensa)
      defensa = null
    }
  }
}
