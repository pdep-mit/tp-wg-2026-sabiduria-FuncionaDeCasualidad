import wollok.game.*

class IndicadorDePesos {
  const property position
  const sistemaDePesos
  const property divisor
  const property lugar

  method image() {
    const pesos = sistemaDePesos.pesosDisponibles()
    if (pesos > 9999 or (divisor > 1 and pesos < divisor)) {
      return "hud_digito_vacio.png"
    }
    const digito = (pesos / divisor).roundDown() % 10
    return "hud_digito_" + lugar + "_" + digito + ".png"
  }

  // Los saldos fuera del rango del rótulo conservan su valor legible.
  method text() = if (lugar == 1 and sistemaDePesos.pesosDisponibles() > 9999) "" + sistemaDePesos.pesosDisponibles() else ""
  method textColor() = "684019"
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
