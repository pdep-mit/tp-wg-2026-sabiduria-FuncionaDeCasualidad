// juego.wpgm configura las dependencias y registra el temporizador de actualización.
import wollok.game.*
import zombies.*
import mapa.*
import pesos.*

object motor {
  var property mapa = null
  var property sistemaDePesos = null
  var property generadorDeZombies = null
  var property enCurso = false
  const recargasDeDefensas = []

  method iniciar(unMapa, unSistemaDePesos, unGeneradorDeZombies) {
    mapa = unMapa
    sistemaDePesos = unSistemaDePesos
    generadorDeZombies = unGeneradorDeZombies
    recargasDeDefensas.clear()
    mapa.crearCasilleros()
    enCurso = true
  }

  method actualizar() {
    if (!enCurso) { return }

    self.eliminarMuertos()
    self.verificarFinDePartida()
    if (!enCurso) { return }

    self.actualizarRecargas()
    sistemaDePesos.actualizar()
    self.actualizarDefensas()
    // Mover y resolver impactos de proyectiles lanzados este tick.
    self.actualizarProyectiles()
    self.eliminarProyectilesImpactados()
    // Un zombie abatido por las defensas no puede morder en este tick.
    self.eliminarMuertos()
    self.actualizarZombies()
    self.eliminarMuertos()
    self.verificarFinDePartida()
    if (!enCurso or generadorDeZombies == null) { return }

    generadorDeZombies.actualizar()
    return
  }

  method actualizarDefensas() {
    mapa.defensas().forEach({ defensa => defensa.actualizar() })
  }

  // Actualiza cada proyectil activo (lo mueve un paso según su velocidad).
  // El polimorfismo garantiza que cualquier tipo de proyectil responde a
  // actualizar() sin que el motor conozca su implementación concreta.
  method actualizarProyectiles() {
    mapa.proyectiles().forEach({ proyectil => proyectil.actualizar() })
  }

  // Retira del juego los proyectiles que ya impactaron o salieron del mapa.
  method eliminarProyectilesImpactados() {
    mapa.proyectiles().filter({ proyectil => proyectil.estaMuerto() }).forEach(
      { proyectil =>
        mapa.quitarProyectil(proyectil)
        if (game.hasVisual(proyectil)) game.removeVisual(proyectil)
      }
    )
  }

  method actualizarZombies() {
    mapa.zombies().forEach({ zombie => zombie.actualizar() })
  }

  method puedeColocarDefensa(defensa, fila, columna) {
    return enCurso and defensa != null
      and mapa.puedeColocarDefensaEn(fila, columna)
      and sistemaDePesos.alcanzaPara(defensa.costo())
      and self.puedeColocarTipoDeDefensa(defensa.tipo())
  }

  method colocarDefensa(defensa, fila, columna) {
    if (!self.puedeColocarDefensa(defensa, fila, columna)) {
      return false
    }
    mapa.colocarDefensa(defensa, fila, columna)
    sistemaDePesos.gastarPesos(defensa.costo())
    game.addVisual(defensa)
    recargasDeDefensas.add(
      new RecargaDeDefensa(
        tipo = defensa.tipo(),
        ticksRestantes = defensa.intervaloDeColocacion()
      )
    )
    return true
  }

  method puedeColocarTipoDeDefensa(tipoDeDefensa) {
    return not recargasDeDefensas.any({ recarga =>
      recarga.tipo() == tipoDeDefensa and recarga.ticksRestantes() > 0
    })
  }

  method actualizarRecargas() {
    recargasDeDefensas.forEach({ recarga => recarga.actualizar() })
    recargasDeDefensas.filter(
      { recarga => recarga.ticksRestantes() == 0 }
    ).forEach({ recarga => recargasDeDefensas.remove(recarga) })
  }

  method eliminarMuertos() {
    mapa.defensas().filter({ defensa => defensa.estaMuerta() }).forEach(
      { defensa =>
        mapa.quitarDefensa(defensa)
        if (game.hasVisual(defensa)) game.removeVisual(defensa)
      }
    )
    mapa.zombies().filter({ zombie => zombie.estaMuerto() }).forEach(
      { zombie =>
        mapa.quitarZombie(zombie)
        if (game.hasVisual(zombie)) game.removeVisual(zombie)
      }
    )
  }

  method verificarFinDePartida() {
    if (mapa.algunZombieLlegoALaCasa()) self.terminar()
  }

  method terminar() {
    enCurso = false
  }
}

class RecargaDeDefensa {
  const property tipo
  var property ticksRestantes

  method actualizar() {
    ticksRestantes = (ticksRestantes - 1).max(0)
  }
}

class IndicadorDePartida {
  const property position
  const motorDeJuego

  method text() = if (motorDeJuego.enCurso()) "Defendé la casa"
                  else "Perdiste: llegaron a la casa"

  method textColor() = if (motorDeJuego.enCurso()) "FFFFFF" else "FF5555"
  method fontSize() = 50
}

class GeneradorDeZombies {
  const property mapa
  const property intervaloDeAparicion
  var ticksDesdeUltimaAparicion = 0

  method actualizar() {
    ticksDesdeUltimaAparicion += 1
    if (ticksDesdeUltimaAparicion >= intervaloDeAparicion) {
      self.generarZombie()
      ticksDesdeUltimaAparicion = 0
    }
  }

  method generarZombie() {
    const zombie = new ZombieComun(
      position = game.at(mapa.columnas() - 1, self.elegirFila()),
      mapa = mapa
    )
    mapa.agregarZombie(zombie)
    game.addVisual(zombie)
  }

  method elegirFila() = (0 .. (mapa.filas() - 1)).anyOne()
}
