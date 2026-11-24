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
   

    if (entidades.generadorDeZombies().oleadaFinalCompletada()) {
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
  const property mapa
  const property intervaloDeAparicion
  var ticksDesdeUltimaAparicion = 0
  const oleadas = [
    new Oleada1(mapa = mapa), 
    new Oleada2(mapa = mapa), 
    new Oleada3(mapa = mapa), 
    new OleadaFinal(mapa = mapa)]

  var indiceOleadaActual = 0

  method oleadaActual() = oleadas.get(indiceOleadaActual)

  method hayMasOleadas() = indiceOleadaActual < oleadas.size()

  method iniciar() {
    if (self.hayMasOleadas()) {
      ticksDesdeUltimaAparicion = 0
      self.oleadaActual().iniciarOleada()
    }
  }

  method actualizar() {
    if (!self.hayMasOleadas()) {
      return false
    }
    const oleada = self.oleadaActual()
    if (oleada.puedeGenerarMas()) {
      ticksDesdeUltimaAparicion += 1
      if (ticksDesdeUltimaAparicion >= intervaloDeAparicion) {
        self.generarEnOleada(oleada)
        ticksDesdeUltimaAparicion = 0
      }
    }

    if (oleada.terminoOleada()) {
      self.avanzarOleada()
    }
    return self.hayMasOleadas()
  }

  method generarEnOleada(oleada) {
    const posicion = oleada.posicionDelZombie()
    self.agregarZombie(oleada.crearProximoZombie(posicion))
    
  }

  method avanzarOleada() {
    indiceOleadaActual += 1
    self.iniciar()
  }

  method agregarZombie(zombie) {
    mapa.agregarZombie(zombie)
    game.addVisual(zombie)
  }

  method oleadaFinalCompletada() = oleadas.last().oleadaFinalCompletada()
  
}

class Oleada {
  const mapa
  const secuenciaZombies
  var indiceActual = 0

  method iniciarOleada() {
    indiceActual = 0
  }

  method puedeGenerarMas() = indiceActual < secuenciaZombies.size()

  method terminoOleada() = !self.puedeGenerarMas() && self.seEliminaronTodosLosZombies()

  method seEliminaronTodosLosZombies() = mapa.entidades().zombies().isEmpty() 

  method crearProximoZombie(posicion) {
    const tipo = secuenciaZombies.get(indiceActual)
    indiceActual += 1
    return self.instanciarZombie(tipo, posicion)
  }

  method instanciarZombie(tipo, posicion) {
    if (tipo == "comun") {
      return new ZombieComun(position = posicion, mapa = mapa)
    } else if (tipo == "albanil") {
      return new ZombieAlbanil(position = posicion, mapa = mapa)
    } else if (tipo == "motoquero") {
      return new ZombieMotoquero(position = posicion, mapa = mapa)
    } else {
      return new ZombieInspector(position = posicion, mapa = mapa)
    }
  }

  method elegirFila() = (0..(mapa.filas() -1)).anyOne()

  method posicionDelZombie() = game.at(mapa.columnas() - 1, self.elegirFila())

}

class Oleada1 inherits Oleada (
  secuenciaZombies = ["comun", "comun", "comun", "albanil"]
) {
}

class Oleada2 inherits Oleada (
  secuenciaZombies = ["comun", "comun", "albanil", "albanil", "motoquero"]
) {
}

class Oleada3 inherits Oleada (
  secuenciaZombies = ["inspector", "albanil", "motoquero", "albanil"]
) {
}

class OleadaFinal inherits Oleada (
  secuenciaZombies = ["motoquero", "motoquero", "comun", "inspector", "albanil", "albanil"]
) {
  method oleadaFinalCompletada() {
    return not self.puedeGenerarMas() && self.seEliminaronTodosLosZombies()
  }
  override method terminoOleada() {
    return self.oleadaFinalCompletada()
  }
}
