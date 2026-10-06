import wollok.game.*
import defensas.*

// Adaptador para wollok.game: mantendrá las teclas y clicks fuera del dominio.
object controles {
  var property motorDeJuego = null
  var property tipoDeDefensaSeleccionada = null

  method iniciar(unMotor) {
    motorDeJuego = unMotor
    keyboard.num1().onPressDo({ self.seleccionarDefensa(1) })
    keyboard.num2().onPressDo({ self.seleccionarDefensa(2) })
    keyboard.num3().onPressDo({ self.seleccionarDefensa(3) })
  }

  method seleccionarDefensa(tecla) {
    if (tecla == 1 or tecla == "1") {
      tipoDeDefensaSeleccionada = "vendecursos"
    } else if (tecla == 2 or tecla == "2") {
      tipoDeDefensaSeleccionada = "verdulero"
    } else if (tecla == 3 or tecla == "3") {
      tipoDeDefensaSeleccionada = "panadero"
    }
  }

  method crearDefensaSeleccionada(fila, columna) {
    const pos = game.at(columna, fila)
    const mapaActual = if (motorDeJuego != null) motorDeJuego.mapa() else null
    const sistemaPesos = if (motorDeJuego != null) motorDeJuego.sistemaDePesos() else null

    if (tipoDeDefensaSeleccionada == "vendecursos") {
      return new Vendecursos(
        position = pos,
        vida = 100,
        costo = 25,
        mapa = mapaActual,
        intervaloDeColocacion = 5,
        intervaloDeAccion = 10,
        sistemaDePesos = sistemaPesos,
        pesosPorVenta = 25
      )
    } else if (tipoDeDefensaSeleccionada == "verdulero") {
      return new Verdulero(
        position = pos,
        vida = 50,
        costo = 10,
        danio = 20,
        mapa = mapaActual,
        intervaloDeColocacion = 5,
        intervaloDeAccion = 10
      )
    } else if (tipoDeDefensaSeleccionada == "panadero") {
      return new Panadero(
        position = pos,
        vida = 300,
        costo = 5,
        mapa = mapaActual,
        intervaloDeColocacion = 30,
        intervaloDeAccion = 1
      )
    } else {
      return null
    }
  }

  method colocarDefensaSeleccionada(fila, columna) {
    if (tipoDeDefensaSeleccionada != null and motorDeJuego != null) {
      const defensa = self.crearDefensaSeleccionada(fila, columna)
      motorDeJuego.colocarDefensa(defensa, fila, columna)
    }
  }
}
