import wollok.game.*
import mapa.*
import pesos.*

object motor {
  var property mapa = null
  var property sistemaDePesos = null
  var property generadorDeZombies = null
  const recargas = []
  var property enCurso = false
  var property gano = false
  var property velocidad = 1

  method inicializar(unMapa, unSistemaDePesos, unGeneradorDeZombies) {
    mapa = unMapa
    sistemaDePesos = unSistemaDePesos
    generadorDeZombies = unGeneradorDeZombies
    mapa.crearCasilleros()
    recargas.clear()
    enCurso = true
    gano = false
    velocidad = 1
  }

  method alternarVelocidad() {
    if (self.enCurso()) { velocidad = if (velocidad == 1) 2 else 1 }
  }

  method actualizarSegunVelocidad() {
    velocidad.times({ i => self.actualizar() })
  }

  method actualizar() {
    if (enCurso) {
      self.actualizarPartida()
    }
  }

  method actualizarPartida() {
    self.actualizables().forEach({ actualizable => actualizable.actualizar() })
    recargas.removeAllSuchThat({ recarga => recarga.termino() })
    self.verificarFinDePartida()
  }

  method actualizables() = recargas + [sistemaDePesos, mapa, generadorDeZombies]

  method verificarFinDePartida() {
    if (mapa.algunZombieLlegoALaCasa()) {
      self.perder()
    } else if (generadorDeZombies.completoTodasLasOleadas()) {
      self.ganar()
    }
  }

  method ganar() {
    gano = true
    enCurso = false
  }

  method perder() {
    enCurso = false
  }

  method puedeColocarDefensa(defensa, fila, columna) {
    return self.enCurso()
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
    recargas.add(new RecargaDeDefensa(tipo = defensa.tipo(), ticksRestantes = defensa.intervaloDeColocacion()))
    return true
  }

  method puedeColocarTipoDeDefensa(tipoDeDefensa) =
    not recargas.any({ recarga => recarga.tipo() == tipoDeDefensa and not recarga.termino() })
}

class RecargaDeDefensa {
  const property tipo
  var property ticksRestantes

  method actualizar() {
    ticksRestantes = (ticksRestantes - 1).max(0)
  }

  method termino() = ticksRestantes == 0
}

class IndicadorDePartida {
  const property position
  const motorDeJuego

  method image() {
    if (motorDeJuego.enCurso()) {
      return "hud_estado_jugando.png"
    }
    return if (motorDeJuego.gano()) "hud_estado_ganaste.png" else "hud_estado_perdiste.png"
  }
}

class IndicadorDeVelocidad {
  const property position
  const motorDeJuego

  method image() = "hud_ritmo_" + motorDeJuego.velocidad() + "x.png"
}
