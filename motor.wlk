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
  var property gano = false

  method iniciar(unMapa, unSistemaDePesos, unGeneradorDeZombies) {
    mapa = unMapa
    sistemaDePesos = unSistemaDePesos
    mapa.crearCasilleros()
    entidades = mapa.entidades()
    entidades.configurar(mapa, sistemaDePesos, unGeneradorDeZombies)
    enCurso = true
    gano = false
  }

  method actualizar() {
    if (!enCurso) { return }

    if (!entidades.actualizar()){
      self.terminar()
      return
    } 
   

    if (entidades.generadorDeZombies().jefeFinalDerrotado()) {
      self.ganar()
      return
    }
    return
  }

  method ganar() {
    gano = true
    enCurso = false
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

  method text() {
    if (motorDeJuego.enCurso()) {
      return "Defendé la casa"
    }
    if (motorDeJuego.gano()) {
      return "¡Ganaste!"
    }
    return "Perdiste: llegaron a la casa"
  }

  method textColor() {
    if (motorDeJuego.enCurso()) {
      return "FFFFFF"
    }

    if (motorDeJuego.gano()) {
      return "00FF00"
    }

    return "FF5555"
  }

  method fontSize() = 50
}

class GeneradorDeZombies {
  var zombiesGenerados = 0
  var oleadaActual = 1
  var cantidadDeZombies = 5
  const property mapa
  const property intervaloDeAparicion
  var ticksDesdeUltimaAparicion = 0

  method actualizar() {
    if (zombiesGenerados < cantidadDeZombies) {
      ticksDesdeUltimaAparicion += 1
      
      if (ticksDesdeUltimaAparicion >= intervaloDeAparicion) {
      self.generarZombie()
      zombiesGenerados += 1
      ticksDesdeUltimaAparicion = 0
      }
    }

    if (self.terminoPrimeraOleada()) {
      self.iniciarSegundaOleada()
      return 
    }

    if (self.terminoSegundaOleada()) {
      self.iniciarTercerOleada()
      return
    }

    if (self.terminoTerceraOleada()) {
      self.iniciarOleadaFinal()
      return
    }

    return true
  }

  method terminoPrimeraOleada() {
    return zombiesGenerados >= cantidadDeZombies and 
      mapa.entidades().zombies().isEmpty() and 
      oleadaActual == 1
  }

  method iniciarSegundaOleada() {
    oleadaActual = 2
    cantidadDeZombies = 7
    zombiesGenerados = 0
    ticksDesdeUltimaAparicion = 0
  }

  method terminoSegundaOleada() {
    return zombiesGenerados >= cantidadDeZombies and 
      mapa.entidades().zombies().isEmpty() and 
      oleadaActual == 2
  }

  method iniciarTercerOleada() {
    oleadaActual = 3
    cantidadDeZombies = 8
    zombiesGenerados = 0
    ticksDesdeUltimaAparicion = 0
  }

  method terminoTerceraOleada() {
    return zombiesGenerados >= cantidadDeZombies and 
      mapa.entidades().zombies().isEmpty() and
      oleadaActual == 3
  }

  method iniciarOleadaFinal() {
    oleadaActual = 4
    cantidadDeZombies = 1
    zombiesGenerados = 0
    ticksDesdeUltimaAparicion = 0
  }

  method generarZombie() {
    const posicion = game.at(mapa.columnas() -1, self.elegirFila())

    const zombie = if (oleadaActual == 4) {
      new ZombieInspector(position = posicion, mapa = mapa)
    } else if (oleadaActual == 3) {
      if (zombiesGenerados < 3) {
        new ZombieComun(position = posicion, mapa = mapa)
      } else if (zombiesGenerados < 6) {
        new ZombieAlbanil(position = posicion, mapa = mapa)
      } else {
        new ZombieMotoquero(position = posicion, mapa = mapa)
      }
  } else if (oleadaActual == 2 and zombiesGenerados >= 4) {
    new ZombieAlbanil(position = posicion, mapa = mapa)
  } else {
    new ZombieComun(position = posicion, mapa = mapa)
  }
  mapa.agregarZombie(zombie)
  game.addVisual(zombie)
    
  }
  method elegirFila() = (0 .. (mapa.filas() - 1)).anyOne()

  method jefeFinalDerrotado() {
    return oleadaActual == 4 and
      zombiesGenerados == cantidadDeZombies and 
      mapa.entidades().zombies().isEmpty()
  }
  
}
