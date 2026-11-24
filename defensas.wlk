import wollok.game.*
import proyectiles.*

class Defensa {
  var property position
  var property vida
  const property mapa
  const property costo
  const property intervaloDeColocacion

  method animacion()

  method tipo()

  method image() = self.animacion().image()

  method actualizar() {
    if (not self.estaMuerto()) {
      self.animacion().actualizar()
      self.actuar()
    }
  }

  method recibirDanio(cantidad) {
    vida = (vida - cantidad).max(0)
  }

  method estaMuerto() = vida <= 0

  method actuar() { }

  method reaccionarAInspector(hayInspector) { }

  method retirarseDe(unMapa) {
    unMapa.quitarDefensa(self)
  }
}

class Verdulero inherits Defensa {
  const property danio
  const property intervaloDeAccion
  var ticksDesdeUltimoDisparo = 0
  const property velocidadDeProyectil = 0.6
  const property animacion = new Animacion(
    imagenQuieta = "verdulero_quieto.png",
    cuadros = [
      "verdulero_ataque_0.png",
      "verdulero_ataque_1.png",
      "verdulero_ataque_2.png"
    ],
    ticksPorCuadro = self.intervaloDeAccion() / 3
  )

  override method tipo() = tipoVerdulero

  method puedeActuar() = ticksDesdeUltimoDisparo >= intervaloDeAccion and not animacion.estaActiva()

  override method actuar() {
    ticksDesdeUltimoDisparo += 1
    if (self.puedeActuar() and self.buscarObjetivo() != null) {
      self.realizarAccion()
      ticksDesdeUltimoDisparo = 0
    }
  }

  method realizarAccion() {
    animacion.iniciar({ self.disparar() })
  }

  method buscarObjetivo() = mapa.zombieMasCercanoEn(position.y(), position.x(), mapa.columnas())

  method disparar() {
    const proyectil = new ProyectilVerdura(
      position = position.right(1),
      danio = danio,
      velocidad = velocidadDeProyectil,
      mapa = mapa
    )
    mapa.agregarProyectil(proyectil)
  }
}

class Panadero inherits Defensa {
  const property animacion = new Animacion(
    imagenQuieta = "panadero_quieto.png",
    cuadros = [
      "panadero_cubrirse_0.png",
      "panadero_cubrirse_1.png",
      "panadero_cubrirse_2.png"
    ],
    ticksPorCuadro = 6
  )

  override method tipo() = tipoPanadero

  override method recibirDanio(cantidad) {
    super(cantidad * 0.7)
    if (not animacion.estaActiva()) animacion.iniciar({ })
  }
}

class Vendecursos inherits Defensa {
  const property sistemaDePesos
  const property pesosPorVenta
  const property intervaloDeAccion
  var ticksDesdeUltimaVenta = 0
  var bloqueado = false
  const property animacion = new Animacion(
    imagenQuieta = "vendecursos_quieto.png",
    cuadros = ["vendecursos_salto_0.png", "vendecursos_salto_1.png"],
    ticksPorCuadro = 10
  )

  override method tipo() = tipoVendecursos

  method estaBloqueado() = bloqueado

  override method reaccionarAInspector(hayInspector) {
    bloqueado = hayInspector
  }

  method puedeActuar() = ticksDesdeUltimaVenta >= intervaloDeAccion and not animacion.estaActiva()

  override method actuar() {
    ticksDesdeUltimaVenta += 1
    if (self.puedeActuar() and not bloqueado) {
      self.realizarAccion()
      ticksDesdeUltimaVenta = 0
    }
  }

  method realizarAccion() {
    animacion.iniciar({ if (not bloqueado) self.generarPesos() })
  }

  method generarPesos() {
    sistemaDePesos.agregarPesos(pesosPorVenta)
  }
}

class TipoDeDefensa {
  method nombre()

  method crear(posicion, mapa, sistemaDePesos)

  method colocarEn(fila, columna, unMotor) =
    unMotor.colocarDefensa(self.crear(game.at(columna, fila), unMotor.mapa(), unMotor.sistemaDePesos()), fila, columna)

  method imagenDeCursor() = "cursor_seleccion.png"
  method imagenDeVistaPrevia() = "defensa_previa_" + self.nombre() + ".png"
  method imagenDeSeleccion(estadoDeRecarga) = "hud_seleccion_" + self.nombre() + "_" + estadoDeRecarga + ".png"
}

object ningunaDefensa {
  method colocarEn(fila, columna, unMotor) = false
  method imagenDeCursor() = "cursor.png"
  method imagenDeVistaPrevia() = "defensa_previa_vacia.png"
  method imagenDeSeleccion(estadoDeRecarga) = "hud_seleccion_ninguna.png"
}

object tipoVendecursos inherits TipoDeDefensa {
  override method nombre() = "vendecursos"

  override method crear(posicion, mapa, sistemaDePesos) = new Vendecursos(
    position = posicion,
    vida = 100,
    costo = 50,
    mapa = mapa,
    intervaloDeColocacion = 30,
    intervaloDeAccion = 60,
    sistemaDePesos = sistemaDePesos,
    pesosPorVenta = 25
  )
}

object tipoVerdulero inherits TipoDeDefensa {
  override method nombre() = "verdulero"

  override method crear(posicion, mapa, sistemaDePesos) = new Verdulero(
    position = posicion,
    vida = 50,
    costo = 100,
    danio = 20,
    mapa = mapa,
    intervaloDeColocacion = 30,
    intervaloDeAccion = 12
  )
}

object tipoPanadero inherits TipoDeDefensa {
  override method nombre() = "panadero"

  override method crear(posicion, mapa, sistemaDePesos) = new Panadero(
    position = posicion,
    vida = 500,
    costo = 50,
    mapa = mapa,
    intervaloDeColocacion = 120
  )
}


class Animacion {
  const imagenQuieta
  const cuadros
  const ticksPorCuadro
  var indiceDeCuadro = 0
  var contadorTicks = 0
  var activo = false
  var alIniciarUltimoCuadro = { 
    
  }
  
  method image() = if (!activo) imagenQuieta else cuadros.get(indiceDeCuadro)
  
  method estaActiva() = activo
  
  method iniciar(accion) {
    indiceDeCuadro = 0
    contadorTicks = 0
    alIniciarUltimoCuadro = accion
    activo = true
    if (indiceDeCuadro == (cuadros.size() - 1)) alIniciarUltimoCuadro.apply()
  }
  
  method avanzarCuadro() {
    indiceDeCuadro = (indiceDeCuadro + 1).min(cuadros.size())
    if (indiceDeCuadro == (cuadros.size() - 1)) alIniciarUltimoCuadro.apply()
  }
  
  method actualizar() {
    if (!activo) {
      return
    }
    
    contadorTicks += 1
    if (contadorTicks >= ticksPorCuadro) {
      self.avanzarCuadro()
      contadorTicks = 0
    }
    
    
    if (indiceDeCuadro >= cuadros.size()) {
      activo = false
      contadorTicks = 0
      indiceDeCuadro = 0
    }
    return
  }
}
