import wollok.game.*
import defensas.*

// Concentra los valores de balance y crea una instancia nueva por colocación.
class FabricaDeDefensas {
  const mapa
  const sistemaDePesos

  method crear(tipo, fila, columna) {
    const posicion = game.at(columna, fila)

    if (tipo == "vendecursos") {
      return new Vendecursos(
        position = posicion,
        vida = 100,
        costo = 50,
        mapa = mapa,
        intervaloDeColocacion = 10,
        intervaloDeAccion = 100,
        sistemaDePesos = sistemaDePesos,
        pesosPorVenta = 25
      )
    }
    if (tipo == "verdulero") {
      return new Verdulero(
        position = posicion,
        vida = 50,
        costo = 100,
        danio = 20,
        mapa = mapa,
        intervaloDeColocacion = 10,
        intervaloDeAccion = 15
      )
    }
    if (tipo == "panadero") {
      return new Panadero(
        position = posicion,
        vida = 500,
        costo = 50,
        mapa = mapa,
        intervaloDeColocacion = 50
      )
    }
    return null
  }
}
