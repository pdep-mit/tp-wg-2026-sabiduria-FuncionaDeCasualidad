import wollok.game.*
import fabricaDeDefensas.*

// Adaptador para wollok.game: mantiene las teclas fuera del dominio.
object controles {
  var property motorDeJuego = null
  var property tipoDeDefensaSeleccionada = null

  method iniciar(unMotor) {
    motorDeJuego = unMotor
    tipoDeDefensaSeleccionada = null
    cursor.position(game.at(0, 0))
    if (!game.hasVisual(vistaPreviaDeDefensa)) {
      game.addVisual(vistaPreviaDeDefensa)
    }
    if (!game.hasVisual(cursor)) {
      game.addVisual(cursor)
    }
    keyboard.num1().onPressDo({ self.seleccionarDefensa(1) })
    keyboard.num2().onPressDo({ self.seleccionarDefensa(2) })
    keyboard.num3().onPressDo({ self.seleccionarDefensa(3) })
    keyboard.r().onPressDo({ motorDeJuego.alternarVelocidad() })
    keyboard.up().onPressDo({ self.moverCursor(0, 1) })
    keyboard.down().onPressDo({ self.moverCursor(0, -1) })
    keyboard.left().onPressDo({ self.moverCursor(-1, 0) })
    keyboard.right().onPressDo({ self.moverCursor(1, 0) })
    keyboard.enter().onPressDo({ self.colocarEnCursor() })
    game.onClickDo({ posicion => self.seleccionarDefensaEnPanel(posicion) })
  }

  method moverCursor(deltaColumna, deltaFila) {
    if (motorDeJuego == null) { return }

    const columna = cursor.position().x() + deltaColumna
    const fila = cursor.position().y() + deltaFila
    if (!motorDeJuego.mapa().contiene(fila, columna)) { return }

    cursor.position(game.at(columna, fila))
    return
  }

  method colocarEnCursor() {
    self.colocarDefensaSeleccionada(cursor.position().y(), cursor.position().x())
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

  method seleccionarDefensaEnPanel(posicion) {
    if (posicion.y().roundDown() != 5) { return }
    const columna = posicion.x().roundDown()
    if (columna >= 6 and columna <= 8) {
      self.seleccionarDefensa(columna - 5)
    }
    return
  }

  method crearDefensaSeleccionada(fila, columna) {
    const fabrica = new FabricaDeDefensas(
      mapa = if (motorDeJuego != null) motorDeJuego.mapa() else null,
      sistemaDePesos = if (motorDeJuego != null) motorDeJuego.sistemaDePesos() else null
    )
    return fabrica.crear(tipoDeDefensaSeleccionada, fila, columna)
  }

  method colocarDefensaSeleccionada(fila, columna) {
    if (tipoDeDefensaSeleccionada == null or motorDeJuego == null) { return }

    const defensa = self.crearDefensaSeleccionada(fila, columna)
    if (!motorDeJuego.colocarDefensa(defensa, fila, columna)) { return }

    // El cursor se dibuja sobre la defensa recién agregada.
    game.removeVisual(cursor)
    game.addVisual(cursor)
    return
  }
}

object cursor {
  var property position = game.at(0, 0)

  method image() = if (controles.tipoDeDefensaSeleccionada() == null) "cursor.png" else "cursor_seleccion.png"
}

object vistaPreviaDeDefensa {
  method position() = cursor.position()

  method image() {
    const tipo = controles.tipoDeDefensaSeleccionada()
    const motorDeJuego = controles.motorDeJuego()
    if (tipo == null or motorDeJuego == null or not motorDeJuego.enCurso()) {
      return "defensa_previa_vacia.png"
    }

    const posicion = self.position()
    if (not motorDeJuego.mapa().puedeColocarDefensaEn(posicion.y(), posicion.x())) {
      return "defensa_previa_vacia.png"
    }
    return "defensa_previa_" + tipo + ".png"
  }
}

class PanelSuperior {
  const property position

  method image() = "hud_panel.png"
}

class IndicadorDeSeleccion {
  const property position
  const controlesDeJuego

  method image() {
    const tipo = controlesDeJuego.tipoDeDefensaSeleccionada()
    if (tipo == null) { return "hud_seleccion_ninguna.png" }
    const estado = if (controlesDeJuego.motorDeJuego().puedeColocarTipoDeDefensa(tipo)) "listo" else "recarga"
    return "hud_seleccion_" + tipo + "_" + estado + ".png"
  }
}
