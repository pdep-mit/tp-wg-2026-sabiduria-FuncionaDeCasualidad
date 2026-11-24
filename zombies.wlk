import wollok.game.*

class Zombie {
  var property position
  var property vida
  var property casillasPorPaso = 1
  const property mapa
  const ticksEntrePasos = 90 // 1.5 segundos a 60 ticks por segundo
  var ticksDesdeUltimoPaso = 0
  const property danio
  const property intervaloDeAtaque = 30 // medio segundo entre mordiscos
  var property ticksDesdeUltimoAtaque = 0
  var property ticksAnimacionDanio = 0
  const property imagenDanio 
  var property imagenZombieGana 
  var property imagenZombieActual 
  const property imagenZombie2 
  const property imagenZombieBase 
  const property imagenZombieAtaca1
  const property imagenZombieAtaca2 
  
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
    const siguienteColumna = (position.x() - casillasPorPaso).max(0)
    // Busca en todo el tramo del paso dónde debe frenar frente a una defensa.
    const defensasEnElPaso = mapa.defensas().filter({ defensa =>
      !defensa.estaMuerta() and defensa.position().y() == position.y()
        and (defensa.position().x() + 1).between(siguienteColumna, position.x())
    }).sortedBy({ primera, segunda => primera.position().x() > segunda.position().x() })
    if (defensasEnElPaso.isEmpty()) {
      position = game.at(siguienteColumna, position.y())
    } else {
      position = game.at(defensasEnElPaso.first().position().x() + 1, position.y())
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
    // El zombie muerde a la defensa que está justo a su izquierda.
    const defensa = mapa.defensaEn(position.y(), position.x() - 1)
    return if (defensa != null and !defensa.estaMuerta()) defensa else null
  }

  method atacar(defensa) {
    ticksDesdeUltimoAtaque += 1
    if (ticksDesdeUltimoAtaque <= intervaloDeAtaque / 2) {
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
    ticksAnimacionDanio = 12
  }

  method estaMuerto() = vida <= 0

  method esInspector() = false

  method llegoALaCasa() = position.x() <= 0
}

class ZombieComun inherits Zombie (
  vida = 100, 
  danio = 10, 
  imagenDanio = "zombieComun_recibe_ataque.png",
  imagenZombieGana = "zombieComun_gana.png", 
  imagenZombieActual = "zombieComun1.png",
  imagenZombie2 = "zombieComun2.png",
  imagenZombieBase = "zombieComun1.png",
  imagenZombieAtaca1 = "zombieComun_ataque_1.png",
  imagenZombieAtaca2 = "zombieComun_ataque_2.png") {

}

class ZombieAlbanil inherits Zombie (
  vida = 300,
  danio = 10,
  imagenDanio = "zombieAlbanil_recibe_ataque.png", 
  imagenZombieGana = "zombieAlbanil_gana.png",     
  imagenZombieActual = "zombieAlbanil1.png",
  imagenZombie2 = "zombieAlbanil2.png",
  imagenZombieBase = "zombieAlbanil1.png",
  imagenZombieAtaca1 = "zombieAlbanil_ataque_1.png",
  imagenZombieAtaca2 = "zombieAlbanil_ataque_2.png") {

}

class ZombieMotoquero inherits Zombie (
  vida = 100, 
  danio = 10, 
  imagenDanio = "zombieComun_recibe_ataque.png", //assets del zombieComun
  imagenZombieGana = "zombieMotoquero_gana.png", 
  imagenZombieActual = "zombieComun1.png",
  imagenZombie2 = "zombieComun2.png",
  imagenZombieBase = "zombieComun1.png",
  imagenZombieAtaca1 = "zombieComun_ataque_1.png",
  imagenZombieAtaca2 = "zombieComun_ataque_2.png") {

    var modo = new ModoMotoquero(zombie = self)

    override method initialize() {
      super()
      modo.aplicarAlZombie()
    }

    method bajarDeLaMoto() {
      modo = new ModoComun(zombie = self)
      imagenZombieGana = "zombieComun_gana.png"
      modo.aplicarAlZombie()
    }

    override method recibirDanio(cantidad) {
      modo.recibirDanio(cantidad)
    }

    override method atacar(defensa) {
      modo.atacar(defensa)
    }

    override method cambiarPaso() {
      modo.cambiarPaso()
    }

}

class ModoMotoquero {
  const zombie
  const imagenMotoBase = "zombieMotoquero.png"
  const imagenMotoGana = "zombieMotoquero_gana.png"

  method aplicarAlZombie() {
    zombie.imagenZombieActual(imagenMotoBase)
  }
  
  method imagenGana() = imagenMotoGana

  method cambiarPaso() {
    zombie.imagenZombieActual(if(zombie.llegoALaCasa()) imagenMotoGana else imagenMotoBase)
  }

  method recibirDanio(cantidad) {
    //no recibe danio mientras esta en modo motoquero
  }

  method atacar(defensa) {
    zombie.bajarDeLaMoto()
  }
}

class ModoComun {
  const zombie

  method aplicarAlZombie() {
    zombie.imagenZombieActual(zombie.imagenZombieBase())
  }

  method imagenGana() = zombie.imagenZombieGana()

  method cambiarPaso() {
    if (zombie.llegoALaCasa()) {
      zombie.imagenZombieActual(zombie.imagenZombieGana())
    } else if (zombie.imagenZombieActual() == zombie.imagenZombieBase()) {
      zombie.imagenZombieActual(zombie.imagenZombie2())
    } else {
      zombie.imagenZombieActual(zombie.imagenZombieBase())
    }
  }

  method recibirDanio(cantidad) {
    zombie.vida((zombie.vida() - cantidad).max(0))
    zombie.ticksAnimacionDanio(12)
  }

  method atacar(defensa) {
    const ticks = zombie.ticksDesdeUltimoAtaque() + 1
    zombie.ticksDesdeUltimoAtaque(ticks)
    if (ticks <= zombie.intervaloDeAtaque() / 2) {
      zombie.imagenZombieActual(zombie.imagenZombieAtaca1())
    } else {
      zombie.imagenZombieActual(zombie.imagenZombieAtaca2())
    }
    if (ticks >= zombie.intervaloDeAtaque()) {
      defensa.recibirDanio(zombie.danio())
      zombie.ticksDesdeUltimoAtaque(0)
    }
  }
}

class ZombieInspector inherits Zombie (
  vida = 100, 
  danio = 10, 
  imagenDanio = "zombieInspector_recibe_ataque.png",
  imagenZombieGana = "zombieInspector_gana.png", 
  imagenZombieActual = "zombieInspector1.png",
  imagenZombie2 = "zombieInspector2.png",
  imagenZombieBase = "zombieInspector1.png",
  imagenZombieAtaca1 = "zombieInspector_ataque_1.png",
  imagenZombieAtaca2 = "zombieInspector_ataque_2.png") {

    override method esInspector() = true
}
