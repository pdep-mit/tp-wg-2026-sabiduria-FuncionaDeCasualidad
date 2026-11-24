import wollok.game.*

class ProyectilVerdura {
  var property position
  const property danio
  const property velocidad
  const property mapa
  var muerto = false
  
  method image() = "tomate_alto.png"
  
  method estaMuerto() = muerto

  method retirarseDe(unMapa) {
    unMapa.quitarProyectil(self)
  }
  
  method actualizar() {
    if (muerto) {
      return
    }
    
    const xAnterior = position.x()
    position = position.right(velocidad)

    const zombieImpactado = self.buscarZombieImpactado(xAnterior, position.x())
    if (zombieImpactado != null) {
      self.impactar(zombieImpactado)
      return
    }
    
    if (position.x() >= mapa.columnas()) {
      muerto = true
    }
    return
  }
  
  method buscarZombieImpactado(xDesde, xHasta) = mapa.zombieMasCercanoEn(position.y(), xDesde, xHasta)
  
  method impactar(zombie) {
    zombie.recibirDanio(danio)
    muerto = true
  }
}
