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
  const animacion = new Animacion(
    imagenQuieta = "verdulero_quieto.png",
    cuadros = ["verdulero_ataque_0.png", "verdulero_ataque_1.png", "verdulero_ataque_2.png"],
    ticksPorCuadro = self.intervaloDeAccion() / 3
  )
  
  method image() = animacion.image()
  
  method tipo() = "verdulero"
  
  method recibirDanio(cantidad) {
    vida -= cantidad
  }
  
  method estaMuerta() = vida <= 0

  method puedeActuar() = ticksDesdeUltimaAccion >= intervaloDeAccion and !animacion.estaActiva()


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
    self.animarAtaque(zombie)
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
  
  method animarAtaque(zombie) {
    animacion.iniciar({ =>
      if (!zombie.estaMuerto()) {
        zombie.recibirDanio(danio)
      }
    })
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
  const animacion = new Animacion(
    imagenQuieta = "panadero_quieto.png",
    cuadros = ["panadero_cubrirse_0.png", "panadero_cubrirse_1.png", "panadero_cubrirse_2.png"],
    ticksPorCuadro = 6
  )
  
  method image() = animacion.image()
  
  method tipo() = "panadero"
  
  method recibirDanio(cantidad) {
    vida -= cantidad
    // Se cubre con los panes al recibir daño.
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
    if (!animacion.estaActiva()) {
      animacion.iniciar({ => })
    }
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
  const animacion = new Animacion(
    imagenQuieta = "vendecursos_quieto.png",
    cuadros = ["vendecursos_salto_0.png", "vendecursos_salto_1.png"],
    ticksPorCuadro = 60
  )
  
  method image() = animacion.image()
  
  method tipo() = "vendecursos"
  
  method recibirDanio(cantidad) {
    vida -= cantidad
  }
  
  method estaMuerta() = vida <= 0

  method puedeActuar() = ticksDesdeUltimaAccion >= intervaloDeAccion and !animacion.estaActiva()


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
    if (!self.puedeActuar() or self.estaBloqueado()) { return }


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
    animacion.iniciar({ =>
      if (!self.estaBloqueado()) {
        self.generarPesos()
      }
    })
  }
} // Cada acción inicia una secuencia; cada tick muestra el siguiente cuadro.

// Cada cuadro dura los ticks indicados; el bloque se ejecuta al entrar al último.
class Animacion {
  const imagenQuieta
  const cuadros
  const ticksPorCuadro
  var indiceDeCuadro = 0
  var contadorTicks = 0
  var activo = false
  var alIniciarUltimoCuadro = { => }

  method image() = if (!activo) imagenQuieta else cuadros.get(indiceDeCuadro)
  method estaActiva() = activo

  method iniciar(accion) {
    indiceDeCuadro = 0
    contadorTicks = 0
    alIniciarUltimoCuadro = accion
    activo = true
    if (indiceDeCuadro == cuadros.size() - 1) {
      alIniciarUltimoCuadro.apply()
    }
  }

  method avanzarCuadro() {
    indiceDeCuadro = (indiceDeCuadro + 1).min(cuadros.size())
    if (indiceDeCuadro == cuadros.size() - 1) {
      alIniciarUltimoCuadro.apply()
    }
  }
  
  method actualizar() {
    if (!activo) { return }

    contadorTicks += 1
    if (contadorTicks >= ticksPorCuadro) {
      self.avanzarCuadro()
      contadorTicks = 0
    }


    if (indiceDeCuadro >= cuadros.size()) {
      activo = false
      contadorTicks = 0
      indiceDeCuadro = 0
    }
    return
  }
}