import wollok.game.*

// Todas las defensas responden a actualizar(). El motor puede enviar
// ese mismo mensaje a cualquiera de ellas sin preguntar su tipo.
// No hay herencia ni clase base: el polimorfismo surge de que todas
// entienden el mismo protocolo.

// ──────────────────────────────────────────────────────────────────
// Verdulero: lanza verduras hacia los enemigos en su misma fila.
// Alcance de toda la línea, daño básico, costo normal.
// ──────────────────────────────────────────────────────────────────
class Verdulero {
  var property position
  var property vida
  const property costo
  const property danio
  const property mapa
  const property intervaloDeColocacion
  const property intervaloDeAccion
  var ticksDesdeUltimaAccion = 0
  var imagenActual = "verdulero_quieto.png"

  method image() = imagenActual

  // ── Vida y resistencia ──
  method recibirDanio(cantidad) {
    vida = vida - cantidad
  }

  method estaMuerta() = vida <= 0

  // ── Intervalo de acción ──
  method puedeActuar() = ticksDesdeUltimaAccion >= intervaloDeAccion

  // ── Actualización por tick ──
  // El motor envía este mensaje cada tick. El Verdulero busca un
  // objetivo en su fila y lo ataca si puede actuar.
  method actualizar() {
    ticksDesdeUltimaAccion = ticksDesdeUltimaAccion + 1
    if (self.puedeActuar()) {
      const objetivo = self.buscarObjetivo()
      if (objetivo != null) {
        self.atacar(objetivo)
        ticksDesdeUltimaAccion = 0
      }
    }
  }

  // ── Búsqueda de objetivo ──
  // Busca un zombie en la misma fila. Depende de que el mapa
  // implemente zombiesEnLinea(fila).
  method buscarObjetivo() {
    const zombiesEnMiFila = mapa.zombiesEnLinea(position.y())
    if (zombiesEnMiFila.isEmpty()) {
      return null
    }
    return zombiesEnMiFila.first()
  }

  // ── Ataque ──
  method atacar(zombie) {
    self.animarAtaque()
    zombie.recibirDanio(danio)
  }

  // Cicla entre los frames de ataque para feedback visual.
  method animarAtaque() {
    if (imagenActual == "verdulero_quieto.png") {
      imagenActual = "verdulero_ataque_0.png"
    } else if (imagenActual == "verdulero_ataque_0.png") {
      imagenActual = "verdulero_ataque_1.png"
    } else if (imagenActual == "verdulero_ataque_1.png") {
      imagenActual = "verdulero_ataque_2.png"
    } else {
      imagenActual = "verdulero_quieto.png"
    }
  }
}

// ──────────────────────────────────────────────────────────────────
// Panadero: barrera defensiva de alta vida. Deja un canasto de
// panes viejos que aguanta muchos golpes. Costo barato, recarga alta.
// No ataca: su función es absorber daño.
// ──────────────────────────────────────────────────────────────────
class Panadero {
  var property position
  var property vida
  const property costo
  const property mapa
  const property intervaloDeColocacion
  const property intervaloDeAccion
  var ticksDesdeUltimaAccion = 0
  var imagenActual = "panadero_quieto.png"

  method image() = imagenActual

  // ── Vida y resistencia ──
  method recibirDanio(cantidad) {
    vida = vida - cantidad
    // Feedback visual: cambia de pose al recibir daño.
    self.animarDanio()
  }

  method estaMuerta() = vida <= 0

  // ── Intervalo de acción ──
  method puedeActuar() = ticksDesdeUltimaAccion >= intervaloDeAccion

  // ── Actualización por tick ──
  // El Panadero es una barrera pasiva. Su actualizar() solo
  // incrementa el contador de ticks. No necesita buscar objetivos.
  method actualizar() {
    ticksDesdeUltimaAccion = ticksDesdeUltimaAccion + 1
  }

  // Alterna imagen al recibir golpes para dar feedback visual.
  method animarDanio() {
    if (imagenActual == "panadero_quieto.png") {
      imagenActual = "panadero_brazos_cerrados.png"
    } else {
      imagenActual = "panadero_quieto.png"
    }
  }
}

// ──────────────────────────────────────────────────────────────────
// Vendecursos: genera pesos periódicamente vendiendo cursos.
// No ataca directamente. Puede ser bloqueado por un zombie inspector
// (para una futura iteración).
// ──────────────────────────────────────────────────────────────────
class Vendecursos {
  var property position
  var property vida
  const property costo
  const property mapa
  const property intervaloDeColocacion
  const property intervaloDeAccion
  var ticksDesdeUltimaAccion = 0
  const property sistemaDePesos
  const property pesosPorVenta
  var property bloqueado = false
  var imagenActual = "vendecursos_quieto.png"

  method image() = imagenActual

  // ── Vida y resistencia ──
  method recibirDanio(cantidad) {
    vida = vida - cantidad
  }

  method estaMuerta() = vida <= 0

  // ── Intervalo de acción ──
  method puedeActuar() = ticksDesdeUltimaAccion >= intervaloDeAccion

  // ── Bloqueo por inspector ──
  // Un zombie inspector puede bloquear al vendecursos para que
  // no genere pesos hasta que el inspector muera.
  method estaBloqueado() = bloqueado

  method bloquear() { bloqueado = true }
  method desbloquear() { bloqueado = false }

  // ── Actualización por tick ──
  // El motor envía este mensaje cada tick. Si puede actuar y no
  // está bloqueado, genera pesos.
  method actualizar() {
    ticksDesdeUltimaAccion = ticksDesdeUltimaAccion + 1
    if (self.puedeActuar() && !self.estaBloqueado()) {
      self.generarPesos()
      ticksDesdeUltimaAccion = 0
      self.animarVenta()
    }
  }

  // ── Generación de pesos ──
  method generarPesos() {
    sistemaDePesos.agregarPesos(pesosPorVenta)
  }

  // Cicla entre los frames de salto al vender.
  method animarVenta() {
    if (imagenActual == "vendecursos_quieto.png") {
      imagenActual = "vendecursos_salto_0.png"
    } else if (imagenActual == "vendecursos_salto_0.png") {
      imagenActual = "vendecursos_salto_1.png"
    } else {
      imagenActual = "vendecursos_quieto.png"
    }
  }
}
