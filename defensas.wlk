// Los valores de balance se reciben al construir cada defensa.
// No se asignan vida, costos ni tiempos arbitrarios.
// Cada defensa declara sus propios atributos y responde a actualizar().
// El motor puede enviar el mismo mensaje a todas sin una clase base.

// NOTA: Dejar Vendecursos para lo último, priorizar Verdulero y Panadero
class Vendecursos {
  var property vida
  const property costo
  var property fila
  var property columna
  const property mapa
  // Recarga para volver a colocar este tipo; distinta del intervalo de acción.
  const property intervaloDeColocacion
  const property intervaloDeAccion
  var ticksDesdeUltimaAccion = 0
  const property sistemaDePesos
  const property pesosPorVenta

  method recibirDanio(cantidad) { /* TODO: reducir vida. */ }
  method estaMuerta() { /* TODO: indicar si vida <= 0. */ }
  method puedeActuar() { /* TODO: consultar su intervalo de acción. */ }
  method actualizar() { /* TODO: vender periódicamente si está habilitado. */ }
  method generarPesos() { /* TODO: acreditar pesosPorVenta. */ }
  method estaBloqueado() { /* TODO: consultar si hay inspectores vivos en el mapa. */ }
}

class Verdulero {
  var property vida
  const property costo
  var property fila
  var property columna
  const property mapa
  // Recarga para volver a colocar este tipo; distinta del intervalo de acción.
  const property intervaloDeColocacion
  const property intervaloDeAccion
  var ticksDesdeUltimaAccion = 0
  const property danio

  method recibirDanio(cantidad) { /* TODO: reducir vida. */ }
  method estaMuerta() { /* TODO: indicar si vida <= 0. */ }
  method puedeActuar() { /* TODO: consultar su intervalo de acción. */ }
  method actualizar() { /* TODO: buscar y atacar zombies de su línea. */ }
  method buscarObjetivo() { /* TODO: elegir un zombie de la misma fila. */ }
  method atacar(zombie) { /* TODO: infligir daño básico. */ }
}

class Panadero {
  var property vida
  const property costo
  var property fila
  var property columna
  const property mapa
  // Recarga para volver a colocar este tipo; distinta del intervalo de acción.
  const property intervaloDeColocacion
  const property intervaloDeAccion
  var ticksDesdeUltimaAccion = 0

  method recibirDanio(cantidad) { /* TODO: reducir vida. */ }
  method estaMuerta() { /* TODO: indicar si vida <= 0. */ }
  method puedeActuar() { /* TODO: consultar su intervalo de acción. */ }
  method actualizar() { /* TODO: completar su función de barrera. */ }
}