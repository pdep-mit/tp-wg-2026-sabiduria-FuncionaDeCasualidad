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
  var property velocidadDoble = false

  method iniciar(unMapa, unSistemaDePesos, unGeneradorDeZombies) {
    mapa = unMapa
    sistemaDePesos = unSistemaDePesos
    mapa.crearCasilleros()
    entidades = mapa.entidades()
    entidades.configurar(mapa, sistemaDePesos, unGeneradorDeZombies)
    enCurso = true
    gano = false
    velocidadDoble = false
  }

  method alternarVelocidad() {
    if (enCurso) { velocidadDoble = not velocidadDoble }
  }

  method actualizarSegunVelocidad() {
    self.actualizar()
    if (velocidadDoble) { self.actualizar() }
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

  method image() {
    if (motorDeJuego.enCurso()) {
      return "hud_estado_jugando.png"
    }
    if (motorDeJuego.gano()) {
      return "hud_estado_ganaste.png"
    }
    return "hud_estado_perdiste.png"
  }
}

class IndicadorDeVelocidad {
  const property position
  const motorDeJuego

  method image() = if (motorDeJuego.velocidadDoble()) "hud_ritmo_2x.png" else "hud_ritmo_1x.png"
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
        if (oleadaActual == 4) {
          self.generarOleadaFinal()
          zombiesGenerados += cantidadDeZombies
        } else {
          self.generarZombie()
          zombiesGenerados += 1
        }
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
    cantidadDeZombies = 5
    zombiesGenerados = 0
    ticksDesdeUltimaAparicion = 0
  }

  method generarOleadaFinal() {
    const filaDelInspector = self.elegirFila()
    self.agregarZombie(new ZombieInspector(
      position = game.at(mapa.columnas() - 1, filaDelInspector), mapa = mapa
    ))
    (0 .. (mapa.filas() - 1)).filter({ fila => fila != filaDelInspector }).forEach({ fila =>
      self.agregarZombie(new ZombieMotoquero(
        position = game.at(mapa.columnas() - 1, fila), mapa = mapa
      ))
    })
  }

  method generarZombie() {
    const posicion = game.at(mapa.columnas() - 1, self.elegirFila())

    const zombie = if (oleadaActual == 3) {
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
    self.agregarZombie(zombie)
  }

  method agregarZombie(zombie) {
    mapa.agregarZombie(zombie)
    game.addVisual(zombie)
  }
  method elegirFila() = (0 .. (mapa.filas() - 1)).anyOne()

  method jefeFinalDerrotado() {
    return oleadaActual == 4 and
      zombiesGenerados == cantidadDeZombies and 
      not mapa.entidades().zombies().any({ zombie => zombie.esInspector() and not zombie.estaMuerto() })
  }
  
}
