import wollok.game.*

// Conserva las entidades activas y coordina un tick completo de la partida.
class Entidades {
  var property mapa = null
  var defensasActivas = []
  const zombiesActivos = []
  const proyectilesActivos = []
  const recargasDeDefensas = []
  var property sistemaDePesos = null
  var property generadorDeZombies = null

  method configurar(unMapa, unSistemaDePesos, unGeneradorDeZombies) {
    mapa = unMapa
    sistemaDePesos = unSistemaDePesos
    generadorDeZombies = unGeneradorDeZombies
  }

  method reiniciarMapa() {
    // Los casilleros anteriores conservan la lista vieja de defensas.
    defensasActivas = []
    zombiesActivos.clear()
    proyectilesActivos.clear()
    recargasDeDefensas.clear()
  }

  method defensasActivas() = defensasActivas
  method defensas() = defensasActivas.copy()
  method zombies() = zombiesActivos.copy()
  method proyectiles() = proyectilesActivos.copy()

  method agregarZombie(zombie) { zombiesActivos.add(zombie) }
  method quitarZombie(zombie) { zombiesActivos.remove(zombie) }
  method agregarProyectil(proyectil) { proyectilesActivos.add(proyectil) }
  method quitarProyectil(proyectil) { proyectilesActivos.remove(proyectil) }
  method agregarRecarga(recarga) { recargasDeDefensas.add(recarga) }

  method puedeColocarTipoDeDefensa(tipoDeDefensa) {
    return not recargasDeDefensas.any({ recarga =>
      recarga.tipo() == tipoDeDefensa and recarga.ticksRestantes() > 0
    })
  }

  method actualizar() {
    self.eliminarMuertos()
    if (self.algunZombieLlegoALaCasa()) { return false }

    self.actualizarGrupo(recargasDeDefensas.copy())
    self.eliminarRecargasTerminadas()
    self.actualizarGrupo([sistemaDePesos])
    self.actualizarBloqueoVendeCursos()
    self.actualizarGrupo(self.defensas())
    // Se consultan después de las defensas para incluir los disparos de este tick.
    self.actualizarGrupo(self.proyectiles())
    self.eliminarProyectilesImpactados()
    // Un zombie abatido por un proyectil no puede morder en este tick.
    self.eliminarMuertos()
    self.actualizarGrupo(self.zombies())
    self.eliminarMuertos()
    if (self.algunZombieLlegoALaCasa()) { return false }

    if (generadorDeZombies == null) { return true }
    self.actualizarGrupo([generadorDeZombies])
    return true
  }

  method actualizarBloqueoVendeCursos() {
    const hayInspector = self.zombies().any({ zombie => 
    zombie.esInspector() and !zombie.estaMuerto()
    })

    self.defensas().forEach({ defensa => 
    if (defensa.tipo() == "vendecursos") {
      if (hayInspector) {
        defensa.bloquear()
      } else {
        defensa.desbloquear()
      }
    }
    })
  }

  method actualizarGrupo(grupo) {
    grupo.forEach({ entidad => entidad.actualizar() })
  }

  method algunZombieLlegoALaCasa() {
    return zombiesActivos.any({ zombie => zombie.llegoALaCasa() })
  }

  method eliminarRecargasTerminadas() {
    recargasDeDefensas.filter(
      { recarga => recarga.ticksRestantes() == 0 }
    ).forEach({ recarga => recargasDeDefensas.remove(recarga) })
  }

  method eliminarProyectilesImpactados() {
    self.proyectiles().filter({ proyectil => proyectil.estaMuerto() }).forEach(
      { proyectil =>
        self.quitarProyectil(proyectil)
        if (game.hasVisual(proyectil)) game.removeVisual(proyectil)
      }
    )
  }

  method eliminarMuertos() {
    self.defensas().filter({ defensa => defensa.estaMuerta() }).forEach(
      { defensa =>
        mapa.quitarDefensa(defensa)
        if (game.hasVisual(defensa)) game.removeVisual(defensa)
      }
    )
    self.zombies().filter({ zombie => zombie.estaMuerto() }).forEach(
      { zombie =>
        self.quitarZombie(zombie)
        if (game.hasVisual(zombie)) game.removeVisual(zombie)
      }
    )
  }
}
