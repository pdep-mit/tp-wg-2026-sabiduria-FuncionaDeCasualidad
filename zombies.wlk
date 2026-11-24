import wollok.game.*

class Zombie {
  var property position
  var property vida
  const property mapa
  const ticksEntrePasos = 45
  var ticksDesdeUltimoPaso = 0
  const property danio = 10
  const property intervaloDeAtaque = 20
  var ticksDesdeUltimoAtaque = 0
  var ticksAnimacionDanio = 0
  const apariencia
  var imagenActual = null

  override method initialize() {
    super()
    imagenActual = self.imagenDeCaminar()
  }

  method image() = if (ticksAnimacionDanio > 0) self.imagen("_recibe_ataque") else imagenActual

  method imagen(sufijo) = apariencia + sufijo + ".png"

  method imagenDeCaminar() = self.imagen("1")

  method imagenGana() = self.imagen("_gana")

  method actuarEnElTick() {
    if (ticksAnimacionDanio > 0) {
      ticksAnimacionDanio -= 1
    }
    if (self.llegoALaCasa()) {
      imagenActual = self.imagenGana()
      return
    }

    const defensa = self.defensaAlcanzada()
    if (defensa != null) {
      self.atacar(defensa)
      return
    }
    self.gestionarMovimiento()
    return
  }

  method gestionarMovimiento() {
    ticksDesdeUltimoAtaque = 0
    ticksDesdeUltimoPaso += 1
    if (ticksDesdeUltimoPaso < self.ticksEntrePasos()) { return }

    self.avanzar()
    if (self.llegoALaCasa()) {
      imagenActual = self.imagenGana()
    } else {
      self.cambiarPaso()
    }
    ticksDesdeUltimoPaso = 0
    return
  }

  method avanzar() {
    position = position.left(1)
  }

  method cambiarPaso() {
    imagenActual = if (imagenActual == self.imagenDeCaminar()) self.imagen("2") else self.imagenDeCaminar()
  }

  method defensaAlcanzada() {
    const defensa = mapa.defensaEn(position.y(), position.x() - 1)
    return if (defensa != null and !defensa.estaMuerto()) defensa else null
  }

  method atacar(defensa) {
    ticksDesdeUltimoAtaque += 1
    imagenActual = self.imagen(if (ticksDesdeUltimoAtaque <= intervaloDeAtaque / 2) "_ataque_1" else "_ataque_2")
    if (ticksDesdeUltimoAtaque >= intervaloDeAtaque) {
      defensa.recibirDanio(danio)
      ticksDesdeUltimoAtaque = 0
    }
  }

  method recibirDanio(cantidad) {
    vida = (vida - cantidad).max(0)
    ticksAnimacionDanio = 12
  }

  method estaMuerto() = vida <= 0

  method actualizar() {
    if (not self.estaMuerto()) self.actuarEnElTick()
  }

  method retirarseDe(unMapa) {
    unMapa.quitarZombie(self)
  }

  method bloqueaVentas() = false

  method llegoALaCasa() = position.x() <= 0

  method ticksEntrePasos() = ticksEntrePasos
}

class ZombieComun inherits Zombie(vida = 100, apariencia = "zombieComun") { }

class ZombieAlbanil inherits Zombie(vida = 300, apariencia = "zombieAlbanil", ticksEntrePasos = 60) { }

class ZombieMotoquero inherits Zombie(vida = 100, apariencia = "zombieComun") {
  var modo = enMoto

  method bajarDeLaMoto() {
    modo = aPie
    imagenActual = self.imagenDeCaminar()
  }

  override method recibirDanio(cantidad) {
    if (modo.esVulnerable()) super(cantidad)
  }

  override method atacar(defensa) {
    if (modo.puedeMorder()) super(defensa) else self.bajarDeLaMoto()
  }

  override method cambiarPaso() {
    if (modo.caminaConLasPiernas()) super()
  }

  override method imagenDeCaminar() = modo.imagenDeCaminar(super())

  override method imagenGana() = modo.imagenGana(super())

  override method ticksEntrePasos() = modo.ticksEntrePasos(super())
}

object enMoto {
  method esVulnerable() = false
  method puedeMorder() = false
  method caminaConLasPiernas() = false
  method imagenDeCaminar(imagenAPie) = "zombieMotoquero.png"
  method imagenGana(imagenAPie) = "zombieMotoquero_gana.png"
  method ticksEntrePasos(ticksAPie) = 9
}

object aPie {
  method esVulnerable() = true
  method puedeMorder() = true
  method caminaConLasPiernas() = true
  method imagenDeCaminar(imagenAPie) = imagenAPie
  method imagenGana(imagenAPie) = imagenAPie
  method ticksEntrePasos(ticksAPie) = ticksAPie
}

class ZombieInspector inherits Zombie(vida = 100, apariencia = "zombieInspector") {
  override method bloqueaVentas() = not self.estaMuerto()
}

object zombieComun {
  method crear(posicion, mapa) = new ZombieComun(position = posicion, mapa = mapa)
}

object zombieAlbanil {
  method crear(posicion, mapa) = new ZombieAlbanil(position = posicion, mapa = mapa)
}

object zombieMotoquero {
  method crear(posicion, mapa) = new ZombieMotoquero(position = posicion, mapa = mapa)
}

object zombieInspector {
  method crear(posicion, mapa) = new ZombieInspector(position = posicion, mapa = mapa)
}
