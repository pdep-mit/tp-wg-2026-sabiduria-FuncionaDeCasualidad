import wollok.game.*

class Mapa {
  const property filas
  const property columnas
  const property casilleros = []
  const defensas = []
  const zombies = []
  const proyectiles = []

  method crearCasilleros() {
    casilleros.clear()
    defensas.clear()
    zombies.clear()
    proyectiles.clear()
    game.ground("marco-1.png")

    (0 .. filas - 1).forEach({ f =>
      (0 .. columnas - 1).forEach({ c =>
        casilleros.add(new Casillero(fila = f, columna = c))
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
    return columna < columnas - 1
      and casillero != null and not casillero.estaOcupado()
      and not zombies.any({ zombie =>
        not zombie.estaMuerto() and zombie.position().x() == columna
          and zombie.position().y() == fila
      })
  }

  method colocarDefensa(defensa, fila, columna) {
    if (defensas.contains(defensa)) {
      self.error("La defensa ya está colocada en el mapa.")
    }
    if (!self.puedeColocarDefensaEn(fila, columna)) {
      self.error("No se puede colocar la defensa en la posición (" + columna + ", " + fila + ")")
    }
    self.casilleroEn(fila, columna).colocarDefensa(defensa)
    defensas.add(defensa)
    game.addVisual(defensa)
  }

  method quitarDefensa(defensa) {
    self.casilleroEn(defensa.position().y(), defensa.position().x()).quitarDefensa()
    defensas.remove(defensa)
    self.quitarVisual(defensa)
  }

  method defensas() = defensas.copy()
  method zombies() = zombies.copy()
  method proyectiles() = proyectiles.copy()

  method agregarZombie(zombie) {
    zombies.add(zombie)
    game.addVisual(zombie)
  }

  method quitarZombie(zombie) {
    zombies.remove(zombie)
    self.quitarVisual(zombie)
  }

  method agregarProyectil(proyectil) {
    proyectiles.add(proyectil)
    game.addVisual(proyectil)
  }

  method quitarProyectil(proyectil) {
    proyectiles.remove(proyectil)
    self.quitarVisual(proyectil)
  }

  method entidades() = defensas + zombies + proyectiles

  method zombiesEnLinea(fila) = zombies.filter({ zombie => zombie.position().y() == fila })

  method zombieMasCercanoEn(fila, desde, hasta) {
    const candidatos = self.zombiesEnLinea(fila).filter({ zombie =>
      not zombie.estaMuerto() and zombie.position().x().between(desde, hasta)
    })
    return if (candidatos.isEmpty()) null else candidatos.min({ zombie => zombie.position().x() })
  }

  method defensaEn(fila, columna) {
    const casillero = self.casilleroEn(fila, columna)
    return if (casillero == null) null else casillero.defensa()
  }

  method algunZombieLlegoALaCasa() = zombies.any({ zombie => zombie.llegoALaCasa() })

  method actualizar() {
    self.avisarPresenciaDeInspector()
    self.entidades().forEach({ entidad => entidad.actualizar() })
    self.retirarMuertos()
  }

  method avisarPresenciaDeInspector() {
    const hayInspector = zombies.any({ zombie => zombie.bloqueaVentas() })
    self.defensas().forEach({ defensa => defensa.reaccionarAInspector(hayInspector) })
  }

  method retirarMuertos() {
    self.entidades().filter({ entidad => entidad.estaMuerto() }).forEach({ entidad => entidad.retirarseDe(self) })
  }

  method quitarVisual(visual) {
    if (game.hasVisual(visual)) game.removeVisual(visual)
  }
}

class Casillero {
  const property fila
  const property columna
  var defensa = null

  method defensa() = defensa

  method position() = game.at(columna, fila)

  method image() =
    if (columna == 0 and fila.between(0, 4)) "casa-" + (5 - fila) + ".png"
    else if (fila == 2 and columna.odd()) "calle-2.png"
    else "calle-1.png"

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
