import wollok.game.*
import zombies.*

class Oleada {
  const mapa
  const sistemaDePesos
  const nombre = "¡Llega una oleada!"
  const zombiesPendientes
  const intervaloDeAparicion = 100
  const bonusAlTerminar = 50
  var ticksDesdeUltimaAparicion = 0

  method iniciar() {
    ticksDesdeUltimaAparicion = 0
    anunciador.anunciar(nombre)
  }

  method actualizar() {
    if (self.quedanZombiesPorGenerar()) {
      ticksDesdeUltimaAparicion += 1
      if (ticksDesdeUltimaAparicion >= intervaloDeAparicion) {
        self.generarProximoZombie()
        ticksDesdeUltimaAparicion = 0
      }
    }
  }

  method quedanZombiesPorGenerar() = not zombiesPendientes.isEmpty()

  method termino() = not self.quedanZombiesPorGenerar() and mapa.zombies().isEmpty()

  method terminar(generador) {
    sistemaDePesos.agregarPesos(bonusAlTerminar)
    self.continuarPartida(generador)
  }

  method continuarPartida(generador) {
    generador.comenzarSiguienteOleada()
  }

  method cierraLaPartida() = false

  method generarProximoZombie() {
    const tipo = zombiesPendientes.first()
    zombiesPendientes.remove(tipo)
    const zombie = tipo.crear(self.posicionDeAparicion(), mapa)
    mapa.agregarZombie(zombie)
  }

  method posicionDeAparicion() = game.at(mapa.columnas() - 1, (0 .. mapa.filas() - 1).anyOne())
}

class OleadaFinal inherits Oleada {
  override method continuarPartida(generador) {
    generador.completarOleadas()
  }
}

object anunciador {
  var property ultimoMensaje = ""

  method position() = game.at(4, 4)
  method image() = "defensa_previa_vacia.png"

  method anunciar(mensaje) {
    if (not game.hasVisual(self)) game.addVisual(self)
    ultimoMensaje = mensaje
    game.say(self, mensaje)
  }
}

object sinMasOleadas {
  method iniciar() { }
  method actualizar() { }
  method termino() = false
  method cierraLaPartida() = true
}

class GeneradorDeZombies {
  const mapa
  const sistemaDePesos
  const oleadasPendientes = [
    new Oleada(mapa = mapa, sistemaDePesos = sistemaDePesos,
      nombre = "Oleada 1", intervaloDeAparicion = 60,
      zombiesPendientes = self.secuencia(12, [zombieComun, zombieComun, zombieComun, zombieAlbanil])),
    new Oleada(mapa = mapa, sistemaDePesos = sistemaDePesos,
      nombre = "Oleada 2", intervaloDeAparicion = 45,
      zombiesPendientes = self.secuencia(18, [zombieComun, zombieMotoquero, zombieComun, zombieAlbanil])),
    new Oleada(mapa = mapa, sistemaDePesos = sistemaDePesos,
      nombre = "Oleada 3", intervaloDeAparicion = 35,
      zombiesPendientes = self.secuencia(24, [zombieComun, zombieMotoquero, zombieInspector, zombieAlbanil, zombieComun, zombieMotoquero])),
    new Oleada(mapa = mapa, sistemaDePesos = sistemaDePesos,
      nombre = "Oleada 4", intervaloDeAparicion = 28,
      zombiesPendientes = self.secuencia(30, [zombieMotoquero, zombieComun, zombieAlbanil, zombieComun, zombieMotoquero, zombieInspector])),
    new OleadaFinal(mapa = mapa, sistemaDePesos = sistemaDePesos,
      nombre = "¡Oleada final!", intervaloDeAparicion = 22,
      zombiesPendientes = self.secuencia(40, [zombieMotoquero, zombieComun, zombieAlbanil, zombieMotoquero, zombieComun, zombieInspector, zombieAlbanil]))
  ]
  var oleadaActual = sinMasOleadas

  override method initialize() {
    super()
    self.comenzarSiguienteOleada()
  }

  method oleadaActual() = oleadaActual

  method secuencia(cantidad, patron) = (0 .. cantidad - 1).map({ i => patron.get(i % patron.size()) })

  method actualizar() {
    oleadaActual.actualizar()
    if (oleadaActual.termino()) oleadaActual.terminar(self)
  }

  method comenzarSiguienteOleada() {
    oleadaActual = oleadasPendientes.first()
    oleadasPendientes.remove(oleadaActual)
    oleadaActual.iniciar()
  }

  method completarOleadas() {
    oleadaActual = sinMasOleadas
  }

  method completoTodasLasOleadas() = oleadaActual.cierraLaPartida()
}
