// Proyectil lanzado por el Panadero.
// El Panadero es una barrera pasiva y NO dispara proyectiles;
// esta clase queda reservada para usos futuros (ej. versión ofensiva).
// ─────────────────────────────────────────────────────────────────────────────
// (sin implementación por ahora)
// Proyectil lanzado por el Panadero.
// El Panadero es una barrera pasiva y NO dispara proyectiles;
// esta clase queda reservada para usos futuros (ej. versión ofensiva).
// ─────────────────────────────────────────────────────────────────────────────
// (sin implementación por ahora)
import wollok.game.*

class ProyectilVerdura {
  const imagen = "verdura_proyectil.png"
  var property position // posición inicial: la celda del Verdulero
  const property danio // daño que inflige al impactar
  const property velocidad // casillas que avanza por tick
  const property objetivo // zombie al que persigue
  const property mapa // referencia al mapa para chequear colisiones
  var muerto = false
  
  method image() = imagen
  
  // Indica si el proyectil debe ser retirado del juego.
  method estaMuerto() = muerto
  
  method actualizar() {
    if (muerto) {
      return
    }
    
    
    
    // Avanza hacia la derecha en la misma fila.
    const nuevaX = position.x() + velocidad
    position = game.at(nuevaX, position.y())
    
    
    
    // Impacto: el proyectil alcanzó o superó la columna del objetivo.
    if (position.x() >= objetivo.position().x()) {
      self.impactar()
      return
    }
    
    
    
    // Salió del mapa sin impactar -> se descarta.
    if (position.x() >= mapa.columnas()) {
      muerto = true
    }
    return
  }
  
  method impactar() {
    if (!objetivo.estaMuerto()) objetivo.recibirDanio(danio)
    muerto = true
  }
}
// ─────────────────────────────────────────────────────────────────────────────// ─────────────────────────────────────────────────────────────────────────────// Proyectil lanzado por el Panadero.
// El Panadero es una barrera pasiva y NO dispara proyectiles;
// esta clase queda reservada para usos futuros (ej. versión ofensiva).
// ─────────────────────────────────────────────────────────────────────────────
// (sin implementación por ahora)
