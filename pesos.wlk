class SistemaDePesos {
  var property pesosDisponibles
  const property pesosPorGeneracion
  const property intervaloDeGeneracion
  var ticksDesdeUltimaGeneracion = 0


  method actualizar() {
     ticksDesdeUltimaGeneracion += 1
    
    if (ticksDesdeUltimaGeneracion >= intervaloDeGeneracion) {
      pesosDisponibles += pesosPorGeneracion
      ticksDesdeUltimaGeneracion = 0
    }
    }

  method agregarPesos(cantidad) { 
    pesosDisponibles = pesosDisponibles + cantidad
    }

  method alcanzaPara(costo) { 
    return pesosDisponibles >= costo
    }

  method gastarPesos(cantidad) {  
    if (pesosDisponibles >= cantidad) {
      pesosDisponibles = pesosDisponibles - cantidad
    }
    }
}

//Agrego un objeto indicadorDePesos para mostrar la cantidad de pesos disponibles en pantalla.

//object indicadorDePesos {

//Posición en la pantalla donde se va a indicar la cantidad de pesos disponibles
//    var property position = game.at(x, y)

//Mensaje que va a mostrar en pantalla
//    method text() {
//    return "Pesos: " + SistemaDePesos.pesosDisponibles().toString()
//}
//}