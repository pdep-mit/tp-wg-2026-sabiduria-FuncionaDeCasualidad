// Adaptador para wollok.game: mantendrá las teclas y clicks fuera del dominio.
object controles {
  var motorDeJuego = null
  var tipoDeDefensaSeleccionada = null

  method iniciar(unMotor) {
    motorDeJuego = unMotor
    // TODO: registrar las teclas y clicks en wollok.game.
  }
  method seleccionarDefensa(tecla) { /* TODO: 1 Vendecursos, 2 Verdulero, 3 Panadero. */ }
  method crearDefensaSeleccionada(fila, columna) { /* TODO: crear una instancia con su configuración. */ }
  method colocarDefensaSeleccionada(fila, columna) { /* TODO: pedir la colocación al motor. */ }
}
