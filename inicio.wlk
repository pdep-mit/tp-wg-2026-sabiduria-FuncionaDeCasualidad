import wollok.game.*
import zombies.*
import mapa.*

object configuraciones {
    method iniciarZombie(mapa) {
        const zombie = new ZombieComun(position = game.at(18,7))
        game.addVisual(zombie)
        mapa.agregarZombie(zombie)
    }
}