// Proyectil lanzado por el Verdulero.
// Avanza hacia la derecha por tick; impacta al primer zombie vivo en su fila.
import wollok.game.*

class ProyectilVerdura {
  var property position
  const property danio // daño que inflige al impactar
  const property velocidad // casillas que avanza por tick
  const property mapa // referencia al mapa para consultar colisiones
  var muerto = false
  
  method image() = "tomate_alto.png"
  
  // Indica si el proyectil debe ser retirado del juego.
  method estaMuerto() = muerto
  
  method actualizar() {
    if (muerto) {
      return
    }
    
    const xAnterior = position.x()
    const nuevaX = xAnterior + velocidad
    position = game.at(nuevaX, position.y())
    
    const zombieImpactado = self.buscarZombieImpactado(xAnterior, nuevaX)
    if (zombieImpactado != null) {
      self.impactar(zombieImpactado)
      return
    }
    
    if (position.x() >= mapa.columnas()) {
      muerto = true
    }
    return
  }
  
  // Devuelve el zombie vivo más cercano (menor x) dentro del tramo recorrido,
  // o null si no hay ninguno en ese rango en la misma fila.
  method buscarZombieImpactado(xDesde, xHasta) {
    const candidatos = mapa.zombiesEnLinea(position.y()).filter(
      { zombie =>
        ((!zombie.estaMuerto()) and (zombie.position().x() >= xDesde)) and (zombie.position().x() <= xHasta) }
    ).sortedBy({ z1, z2 => z1.position().x() < z2.position().x() })
    
    return if (candidatos.isEmpty()) null else candidatos.first()
  }
  
  method impactar(zombie) {
    zombie.recibirDanio(danio)
    muerto = true
  }
}
