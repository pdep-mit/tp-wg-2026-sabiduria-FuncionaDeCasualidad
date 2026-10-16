import wollok.game.*

class Zombie {
  var property position
  var property vida
  var property casillasPorPaso = 1
  const property mapa
  const ticksEntrePasos = 100
  var ticksDesdeUltimoPaso = 0
  const property danio
  const property intervaloDeAtaque = 2
  var ticksDesdeUltimoAtaque = 0
  var ticksAnimacionDanio = 0
  const imagenDanio 
  const imagenZombieGana 
  var imagenZombieActual 
  const imagenZombie2 
  const imagenZombieBase 
  const imagenZombieAtaca1
  const imagenZombieAtaca2 
  
  method image() {
    if (ticksAnimacionDanio > 0) {
      return imagenDanio
    }
    return imagenZombieActual
  }

  method actualizar() {
    if (self.estaMuerto()) { return }

    if (ticksAnimacionDanio > 0) {
      ticksAnimacionDanio -= 1
    }
    if (self.llegoALaCasa()) {
      imagenZombieActual = imagenZombieGana
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
    if (ticksDesdeUltimoPaso < ticksEntrePasos) { return }

    self.avanzar()
    if (self.llegoALaCasa()) {
      imagenZombieActual = imagenZombieGana
    } else {
      self.cambiarPaso()
    }
    ticksDesdeUltimoPaso = 0
    return
  }

  method avanzar() {
    const siguienteColumna = (position.x() - casillasPorPaso).max(1)
    // Busca en todo el tramo del paso: no depende de igualdades decimales.
    const defensasEnElPaso = mapa.defensas().filter({ defensa =>
      !defensa.estaMuerta() and defensa.position().y() == position.y()
        and defensa.position().x().between(siguienteColumna, position.x())
    }).sortedBy({ primera, segunda => primera.position().x() > segunda.position().x() })
    if (defensasEnElPaso.isEmpty()) {
      position = game.at(siguienteColumna, position.y())
    } else {
      position = game.at(defensasEnElPaso.first().position().x(), position.y())
    }
  }

  method cambiarPaso() {
    if (imagenZombieActual == imagenZombieBase) {
      imagenZombieActual = imagenZombie2
    } else {
      imagenZombieActual = imagenZombieBase
    }
  }

  method defensaAlcanzada() {
    const defensa = mapa.defensaEn(position.y(), position.x())
    return if (defensa != null and !defensa.estaMuerta()) defensa else null
  }

  method atacar(defensa) {
    ticksDesdeUltimoAtaque += 1
    if (ticksDesdeUltimoAtaque % 2 == 0) {
      imagenZombieActual = imagenZombieAtaca1
    } else {
      imagenZombieActual = imagenZombieAtaca2
    }
    if (ticksDesdeUltimoAtaque >= intervaloDeAtaque) {
      defensa.recibirDanio(danio)
      ticksDesdeUltimoAtaque = 0
    }
  }

  method recibirDanio(cantidad) {
    vida = (vida - cantidad).max(0)
    ticksAnimacionDanio = 2
  }

  method estaMuerto() = vida <= 0

  method llegoALaCasa() = position.x() <= 1
}

class ZombieComun inherits Zombie (
  vida = 300, 
  danio = 10, 
  imagenDanio = "zombieComun_recibe_ataque.png",
  imagenZombieGana = "zombieComun_gana.png", 
  imagenZombieActual = "zombieComun1.png",
  imagenZombie2 = "zombieComun2.png",
  imagenZombieBase = "zombieComun1.png",
  imagenZombieAtaca1 = "zombieComun_ataque_1.png",
  imagenZombieAtaca2 = "zombieComun_ataque_2.png") {

}
