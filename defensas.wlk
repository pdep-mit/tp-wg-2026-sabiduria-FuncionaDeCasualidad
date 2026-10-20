import wollok.game.*
import proyectiles.*

// Todas las defensas responden a actualizar(). El motor puede enviar
// ese mismo mensaje a cualquiera de ellas sin preguntar su tipo.
// No hay herencia ni clase base: el polimorfismo surge de que todas
// entienden el mismo protocolo.
// Verdulero: lanza verduras hacia los enemigos en su misma fila.
// Alcance de toda la línea, daño básico, costo normal.
class Verdulero {
  var property position
  var property vida
  const property costo
  const property danio
  const property mapa
  const property intervaloDeColocacion
  const property intervaloDeAccion
  const property velocidadDeProyectil = 1
  var ticksDesdeUltimaAccion = 0
  const animacion = new AnimacionDeDefensa(
    imagenQuieta = "verdulero_quieto.png",
    cuadros = [
      "verdulero_ataque_0.png",
      "verdulero_ataque_1.png",
      "verdulero_ataque_2.png"
    ]
  )
  
  method image() = animacion.image()
  
  method tipo() = "verdulero"
  
  method recibirDanio(cantidad) {
    vida -= cantidad
  }
  
  method estaMuerta() = vida <= 0
  
  method puedeActuar() = ticksDesdeUltimaAccion >= intervaloDeAccion
  
  method actualizar() {
    if (self.estaMuerta()) {
      return
    }
    
    animacion.actualizar()
    ticksDesdeUltimaAccion += 1
    if (!self.puedeActuar()) {
      return
    }
    
    const objetivo = self.buscarObjetivo()
    if (objetivo == null) {
      return
    }
    
    self.atacar(objetivo)
    ticksDesdeUltimaAccion = 0
    return
  }
  
  // Prioriza al zombie vivo más cercano delante de la defensa.
  method buscarObjetivo() {
    const zombiesEnMiFila = mapa.zombiesEnLinea(position.y()).filter(
      { zombie =>
        (!zombie.estaMuerto()) and (zombie.position().x() >= position.x()) }
    ).sortedBy(
      { primero, segundo => primero.position().x() < segundo.position().x() }
    )
    if (zombiesEnMiFila.isEmpty()) {
      return null
    }
    return zombiesEnMiFila.first()
  }
  
  method atacar(zombie) {
    self.animarAtaque()
    self.disparar(zombie)
  }
  
  // Crea un proyectil propio del Verdulero y lo registra en el juego.
  // El motor lo actualizará cada tick de forma polimórfica.
  method disparar(objetivo) {
    const proyectil = new ProyectilVerdura(
      position = position,
      danio = danio,
      velocidad = velocidadDeProyectil,
      objetivo = objetivo,
      mapa = mapa
    )
    mapa.agregarProyectil(proyectil)
    game.addVisual(proyectil)
  }
  
  method animarAtaque() {
    animacion.iniciar()
  }
} // Panadero: barrera defensiva de alta vida. Deja un canasto de

// panes viejos que aguanta muchos golpes. Costo barato, recarga alta.
// No ataca: su función es absorber daño.
class Panadero {
  var property position
  var property vida
  const property costo
  // El panadero no ataca, pero danio = 0 mantiene el protocolo uniforme.
  const property danio = 0
  const property mapa
  const property intervaloDeColocacion
  const animacion = new AnimacionDeDefensa(
    imagenQuieta = "panadero_quieto.png",
    cuadros = ["panadero_brazos_cerrados.png"]
  )
  
  method image() = animacion.image()
  
  method tipo() = "panadero"
  
  method recibirDanio(cantidad) {
    vida -= cantidad
    // Feedback visual: cambia de pose al recibir daño.
    self.animarDanio()
  }
  
  method estaMuerta() = vida <= 0
  
  // Sigue siendo una barrera pasiva; el tick sólo actualiza su imagen.
  method actualizar() {
    if (self.estaMuerta()) {
      return
    }
    animacion.actualizar()
    return
  }
  
  // Barrera pasiva: no dispara proyectiles.
  method disparar(objetivo) {
    
  }
  
  method animarDanio() {
    animacion.iniciar()
  }
} // Vendecursos: genera pesos periódicamente vendiendo cursos.

// No ataca directamente. Puede ser bloqueado por un zombie inspector
// (para una futura iteración).
class Vendecursos {
  var property position
  var property vida
  const property costo
  // No ataca, pero danio = 0 mantiene el protocolo uniforme.
  const property danio = 0
  const property mapa
  const property intervaloDeColocacion
  const property intervaloDeAccion
  var ticksDesdeUltimaAccion = 0
  const property sistemaDePesos
  const property pesosPorVenta
  var property bloqueado = false
  const animacion = new AnimacionDeDefensa(
    imagenQuieta = "vendecursos_quieto.png",
    cuadros = ["vendecursos_salto_0.png", "vendecursos_salto_1.png"]
  )
  
  method image() = animacion.image()
  
  method tipo() = "vendecursos"
  
  method recibirDanio(cantidad) {
    vida -= cantidad
  }
  
  method estaMuerta() = vida <= 0
  
  method puedeActuar() = ticksDesdeUltimaAccion >= intervaloDeAccion
  
  // Un zombie inspector puede bloquear al vendecursos para que
  // no genere pesos hasta que el inspector muera.
  method estaBloqueado() = bloqueado
  
  method bloquear() {
    bloqueado = true
  }
  
  method desbloquear() {
    bloqueado = false
  }
  
  method actualizar() {
    if (self.estaMuerta()) {
      return
    }
    
    animacion.actualizar()
    ticksDesdeUltimaAccion += 1
    if ((!self.puedeActuar()) or self.estaBloqueado()) {
      return
    }
    
    self.generarPesos()
    ticksDesdeUltimaAccion = 0
    self.animarVenta()
    return
  }
  
  method generarPesos() {
    sistemaDePesos.agregarPesos(pesosPorVenta)
  }
  
  // No dispara proyectiles.
  method disparar(objetivo) {
    
  }
  
  method animarVenta() {
    animacion.iniciar()
  }
} // Cada acción inicia una secuencia; cada tick muestra el siguiente cuadro.

class AnimacionDeDefensa {
  const imagenQuieta
  const cuadros
  var indiceDeCuadro = -1
  
  method image() = if (indiceDeCuadro < 0) imagenQuieta
                   else cuadros.get(indiceDeCuadro)
  
  method iniciar() {
    indiceDeCuadro = 0
  }
  
  method actualizar() {
    if (indiceDeCuadro < 0) {
      return
    }
    
    indiceDeCuadro += 1
    if (indiceDeCuadro >= cuadros.size()) {
      indiceDeCuadro = -1
    }
    return
  }
}