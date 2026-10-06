import wollok.game.*

class ZombieComun {
  var property position
  var property vida = 100
  var property velocidad = 1
  const property mapa
  const ticksParaAvanzar = 6
  var ticksAcumulados = 0
  const property danio = 10
  //var property fila
  //var property columna
  const property intervaloDeAtaque = 2
  var ticksDesdeUltimoAtaque = 0
  var ticksAnimacionDanio = 0
  const imagenDanio = "zombie_recibe_ataque.png"
  //var factorDeRalentizacion = 1
  //var ticksDeRalentizacionRestantes = 0
  var imagenActual = "zombie1.png"
  method image() {
    if(ticksAnimacionDanio > 0){
      return imagenDanio
    }
    return imagenActual
  }

  method actualizar() {
    if(!self.estaMuerto()) {
      if(ticksAnimacionDanio > 0){
        ticksAnimacionDanio -= 1
      }
      if(self.llegoALaCasa()){
        imagenActual = "zombie_gana.png"
      } else {
        const defensa = self.defensaAlcanzada()
        if(defensa != null){
          self.atacar(defensa)
        } else{
          self.gestionarMovimiento()
        }
      }
    }
  }

  method gestionarMovimiento(){
    ticksDesdeUltimoAtaque = 0
    ticksAcumulados += 1
    if(ticksAcumulados >= ticksParaAvanzar) {
        self.avanzar()
        self.cambiarPaso()
        ticksAcumulados = 0
      } 
  }

  method avanzar() { 
    if (position.x() > 0) {
      position = position.left(velocidad)
    } 
  }

  method cambiarPaso(){
    if (imagenActual == "zombie1.png"){
      imagenActual = "zombie2.png"
    } else {
      imagenActual = "zombie1.png"
    }
  }

  method defensaAlcanzada() {  
    return mapa.defensaEn(position.y(), position.x())
  }

  method atacar(defensa) { 
    ticksDesdeUltimoAtaque += 1
    if(ticksDesdeUltimoAtaque % 2 == 0){
      imagenActual = "zombie_ataque_1.png"
    } else {
      imagenActual = "zombie_ataque_2.png"
    }
    if(ticksDesdeUltimoAtaque >= intervaloDeAtaque){
      defensa.recibirDanio(danio)
      ticksDesdeUltimoAtaque = 0
    }
  }

  method recibirDanio(cantidad) { 
    vida = (vida - cantidad).max(0)
    ticksAnimacionDanio = 2
  }

  method estaMuerto() = vida == 0

  method llegoALaCasa() = position.x() == 1
  
}
