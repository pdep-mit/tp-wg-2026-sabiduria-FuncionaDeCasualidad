import wollok.game.*

class ZombieComun {
  var property imagen = "zombie1.png"
  var property vida
  var property velocidad
  const property danio
  var property fila
  var property columna
  const property mapa
  const property intervaloDeAtaque
  var ticksDesdeUltimoAtaque = 0
  var factorDeRalentizacion = 1
  var ticksDeRalentizacionRestantes = 0

  method position() = game.at(columna, fila)
  method image() = imagen

  method actualizar() { /* TODO: avanzar o atacar, y actualizar efectos temporales. */ }
  method avanzar() { /* TODO: desplazarse por la misma fila hacia la casa. */ }
  method defensaAlcanzada() { /* TODO: devolver la defensa alcanzada o null. */ }
  method atacar(defensa) { /* TODO: causar daño respetando el intervalo. */ }
  method recibirDanio(cantidad) { /* TODO: reducir vida. */ }
  method estaMuerto() { /* TODO: indicar si vida <= 0. */ }
  method llegoALaCasa() { /* TODO: consultar el límite de llegada. */ }
}
