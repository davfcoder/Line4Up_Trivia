class_name NetworkHelper
extends RefCounted

static func es_mi_turno(turno_actual: int) -> bool:
	if not Global.es_multijugador:
		return true
	return turno_actual == Global.mi_rol_multijugador

static func soy_host() -> bool:
	return Global.mi_rol_multijugador == 1

static func desconectar():
	if Red.peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		Red.peer.close()
	Global.es_multijugador = false
