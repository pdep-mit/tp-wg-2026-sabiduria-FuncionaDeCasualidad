import wollok.game.*

class IndicadorDePesos {
  const property position
  const sistemaDePesos

  method text() = "Pesos: " + sistemaDePesos.pesosDisponibles()
  method textColor() = "FFFF00"
}

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
    pesosDisponibles += cantidad
  }

  method alcanzaPara(costo) = pesosDisponibles >= costo

  method gastarPesos(cantidad) {
    if (pesosDisponibles >= cantidad) {
      pesosDisponibles -= cantidad
    }
  }
}
