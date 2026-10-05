import wollok.game.*
import zombies.*

object configuraciones {
    const zombieDePrueba = new ZombieComun(position = game.at(18,7))

     method iniciar(){
        game.addVisual(zombieDePrueba)
        game.onTick(600, "Avanzar zombie", {zombieDePrueba.avanzar()})
    }

}