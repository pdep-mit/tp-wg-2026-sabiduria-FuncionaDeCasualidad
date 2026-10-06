import wollok.game.*

class FondoDeArriba {
    var property position
    method image() = "tile_terminacion.png"
}

object fondo {
    method iniciar() {
        game.ground("tile_centro.png")
        (0..game.width()-1).forEach({x => 
        const bloqueTecho = new FondoDeArriba(position = game.at(x, game.height() - 1))
        game.addVisual(bloqueTecho)})
    }
} 


	
