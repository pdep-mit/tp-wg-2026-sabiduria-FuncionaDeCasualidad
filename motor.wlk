// juego.wpgm configura las dependencias y registra el temporizador de actualización.
import wollok.game.*
import zombies.*
import mapa.*
import pesos.*

object motor {
  var property mapa = null
  var property sistemaDePesos = null
  var property entidades = null
  var property enCurso = false

  method iniciar(unMapa, unSistemaDePesos, unGeneradorDeZombies) {
    mapa = unMapa
    sistemaDePesos = unSistemaDePesos
    mapa.crearCasilleros()
    entidades = mapa.entidades()
    entidades.configurar(mapa, sistemaDePesos, unGeneradorDeZombies)
    enCurso = true
  }

  method actualizar() {
    if (!enCurso) { return }
    if (!entidades.actualizar()) self.terminar()
    return
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
    entidades.agregarRecarga(
      new RecargaDeDefensa(
        tipo = defensa.tipo(),
        ticksRestantes = defensa.intervaloDeColocacion()
      )
    )
    return true
  }

  method puedeColocarTipoDeDefensa(tipoDeDefensa) {
    return entidades.puedeColocarTipoDeDefensa(tipoDeDefensa)
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
