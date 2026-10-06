import wollok.game.*
import zombies.*
import mapa.*

object configuraciones {
    method iniciarZombie(mapa) {
        const zombie = new ZombieComun(position = game.at(mapa.columnas() - 1, (mapa.filas() / 2).roundDown()), mapa = mapa)
        game.addVisual(zombie)
        mapa.agregarZombie(zombie)
    }
}
