import wollok.game.*
import entidades.*

// Las clases visuales traducen columna/fila a x/y de wollok.game.
class Mapa {
  const property filas
  const property columnas
  const property casilleros = []
  const property entidades = new Entidades()

  method crearCasilleros() {
    casilleros.clear()
    entidades.reiniciarMapa()
    game.ground("marco-1.png")

    (0 .. filas - 1).forEach({ f =>
      (0 .. columnas - 1).forEach({ c =>
        casilleros.add(new Casillero(fila = f, columna = c, defensasActivas = entidades.defensasActivas()))
        game.addVisual(casilleros.last())})
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
    return self.contiene(fila, columna) and columna < columnas - 1
      and casillero != null and not casillero.estaOcupado()
      and not self.zombies().any({ zombie =>
        not zombie.estaMuerto() and zombie.position().x() == columna
          and zombie.position().y() == fila
      })
  }

  method colocarDefensa(defensa, fila, columna) {
    if (entidades.defensasActivas().contains(defensa)) {
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
    return entidades.defensas()
  }

  method agregarZombie(zombie) {
    entidades.agregarZombie(zombie)
  }

  method quitarZombie(zombie) {
    entidades.quitarZombie(zombie)
  }

  method zombies() = entidades.zombies()

  method agregarProyectil(proyectil) {
    entidades.agregarProyectil(proyectil)
  }

  method quitarProyectil(proyectil) {
    entidades.quitarProyectil(proyectil)
  }

  // Devuelve una copia protegida para iterar de forma segura.
  method proyectiles() {
    return entidades.proyectiles()
  }

  method zombiesEnLinea(fila) {
    return self.zombies().filter({ zombie => zombie.position().y() == fila })
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
    return entidades.algunZombieLlegoALaCasa()
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
 method image() = 
 if (columna == 0 and fila == 4) "casa-1.png" 
 else if (columna == 0 and fila == 3) "casa-2.png"
 else if (columna == 0 and fila == 2) "casa-3.png"
 else if (columna == 0 and fila == 1) "casa-4.png"
 else if (columna == 0 and fila == 0) "casa-5.png"
 else if (fila ==2 and columna %2 !== 0) "calle-2.png"
 else "calle-1.png"

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
