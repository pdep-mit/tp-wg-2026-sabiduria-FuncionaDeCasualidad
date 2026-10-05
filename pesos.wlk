class SistemaDePesos {
  var property pesosDisponibles
  const property pesosPorGeneracion
  const property intervaloDeGeneracion
  var ticksDesdeUltimaGeneracion = 0

  method actualizar() { /* TODO: generar pesos al cumplirse el intervalo. */ }
  method agregarPesos(cantidad) { /* TODO: acreditar una cantidad. */ }
  method alcanzaPara(costo) { /* TODO: comparar saldo y costo. */ }
  method gastarPesos(cantidad) { /* TODO: descontar sin permitir saldo negativo. */ }
}
