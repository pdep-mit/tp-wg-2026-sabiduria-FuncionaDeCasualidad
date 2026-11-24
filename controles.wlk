import wollok.game.*
import defensas.*
import motor.*

object controles {
  var property tipoDeDefensaSeleccionada = ningunaDefensa
  const tiposDeDefensa = [tipoVendecursos, tipoVerdulero, tipoPanadero]
  const filaDelPanel = 5
  const primeraColumnaDeRetratos = 6

  method inicializar() {
    tipoDeDefensaSeleccionada = ningunaDefensa
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
    keyboard.r().onPressDo({ motor.alternarVelocidad() })
    keyboard.up().onPressDo({ self.moverCursor(cursor.position().up(1)) })
    keyboard.down().onPressDo({ self.moverCursor(cursor.position().down(1)) })
    keyboard.left().onPressDo({ self.moverCursor(cursor.position().left(1)) })
    keyboard.right().onPressDo({ self.moverCursor(cursor.position().right(1)) })
    keyboard.enter().onPressDo({ self.colocarEnCursor() })
    game.onClickDo({ posicion => self.seleccionarDefensaEnPanel(posicion) })
  }

  method moverCursor(nuevaPosicion) {
    if (motor.mapa().contiene(nuevaPosicion.y(), nuevaPosicion.x())) {
      cursor.position(nuevaPosicion)
    }
  }

  method colocarEnCursor() {
    self.colocarDefensaSeleccionada(cursor.position().y(), cursor.position().x())
  }

  method seleccionarDefensa(numero) {
    if (numero.between(1, tiposDeDefensa.size())) {
      tipoDeDefensaSeleccionada = tiposDeDefensa.get(numero - 1)
    }
  }

  method seleccionarDefensaEnPanel(posicion) {
    if (posicion.y().roundDown() == filaDelPanel) {
      self.seleccionarDefensa(posicion.x().roundDown() - primeraColumnaDeRetratos + 1)
    }
  }

  method crearDefensaSeleccionada(fila, columna) =
    tipoDeDefensaSeleccionada.crear(game.at(columna, fila), motor.mapa(), motor.sistemaDePesos())

  method colocarDefensaSeleccionada(fila, columna) {
    if (tipoDeDefensaSeleccionada.colocarEn(fila, columna, motor)) {
      game.removeVisual(cursor)
      game.addVisual(cursor)
    }
  }
}

object cursor {
  var property position = game.at(0, 0)

  method image() = controles.tipoDeDefensaSeleccionada().imagenDeCursor()
}

object vistaPreviaDeDefensa {
  method position() = cursor.position()

  method image() =
    if (motor.enCurso() and motor.mapa().puedeColocarDefensaEn(self.position().y(), self.position().x()))
      controles.tipoDeDefensaSeleccionada().imagenDeVistaPrevia()
    else "defensa_previa_vacia.png"
}

class PanelSuperior {
  const property position

  method image() = "hud_panel.png"
}

class IndicadorDeSeleccion {
  const property position

  method image() {
    const tipo = controles.tipoDeDefensaSeleccionada()
    return tipo.imagenDeSeleccion(if (motor.puedeColocarTipoDeDefensa(tipo)) "listo" else "recarga")
  }
}
