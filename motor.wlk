// juego.wpgm configura las dependencias y registra el temporizador de actualización.
import wollok.game.*
import zombies.*
import mapa.*
import pesos.*
object motor {
  var mapa = null
  var sistemaDePesos = null
  var generadorDeZombies = null
  var enCurso = false
  const efectos = []
  const recargasDeDefensas = []

  method iniciar(unMapa, unSistemaDePesos, unGeneradorDeZombies) {
    mapa = unMapa
    sistemaDePesos = unSistemaDePesos
    generadorDeZombies = unGeneradorDeZombies
    mapa.crearCasilleros()
    enCurso = true
  }
  method actualizar() {
    if (enCurso) {
      mapa.zombies().forEach({ zombie => zombie.actualizar()})
    }
  }
  method colocarDefensa(defensa, fila, columna) { /* TODO: validar casilla, saldo y recarga antes de colocar y cobrar. */ }
  method puedeColocarTipoDeDefensa(tipoDeDefensa) { /* TODO: consultar la recarga de colocación de ese tipo. */ }
  method actualizarRecargas() { /* TODO: actualizar los tiempos de colocación por tick. */ }
  method eliminarMuertos() { /* TODO: retirar defensas y zombies sin vida. */ }
  method agregarEfecto(efecto) { /* TODO: registrar un efecto temporal como Migas. */ }
  method eliminarEfectosExpirados() { /* TODO: retirar efectos finalizados. */ }
  method verificarFinDePartida() { /* TODO: detectar llegada de zombies a la casa. */ }
  method terminar() { /* TODO: detener la partida. */ }
}

class GeneradorDeZombies {
  const property mapa
  const property intervaloDeAparicion
  var ticksDesdeUltimaAparicion = 0

  method actualizar() { /* TODO: generar un zombie al cumplirse el intervalo. */ }
  method generarZombie() { /* TODO: crear un ZombieComun e incorporarlo al mapa. */ }
  method elegirFila() { /* TODO: elegir una fila válida. */ }
}
