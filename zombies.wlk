import wollok.game.*

class ZombieComun {
  var property position
  var property vida = 100
  var property velocidad = 1
  //const property danio
  //var property fila
  //var property columna
  //const property mapa
  //const property intervaloDeAtaque
  //var ticksDesdeUltimoAtaque = 0
  //var factorDeRalentizacion = 1
  //var ticksDeRalentizacionRestantes = 0
  var imagenActual = "zombie1.png"
  method image() = imagenActual

  method actualizar() { /* TODO: avanzar o atacar, y actualizar efectos temporales. */ }
  method avanzar() { 
    position = position.left(velocidad)
    self.cambiarPaso()
  }
  method cambiarPaso(){
    if (imagenActual == "zombie1.png"){
      imagenActual = "zombie2.png"
    } else {
      imagenActual = "zombie1.png"
    }
  }
  method defensaAlcanzada() { /* TODO: devolver la defensa alcanzada o null. */ }
  method atacar(defensa) { /* TODO: causar daño respetando el intervalo. */ }
  method recibirDanio(cantidad) { /* TODO: reducir vida. */ }
  method estaMuerto() { /* TODO: indicar si vida <= 0. */ }
  method llegoALaCasa() { /* TODO: consultar el límite de llegada. */ }
}
