extends Node

const PUERTO = 7000

signal partida_creada
signal jugador_conectado
signal conexion_fallida
signal servidor_desconectado

# ⚠️ Empezamos en null, se crea nuevo cada vez
var peer: ENetMultiplayerPeer = null

func crear_servidor():
	_limpiar_peer()
	
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PUERTO, 2)
	
	if error == OK:
		multiplayer.multiplayer_peer = peer
		emit_signal("partida_creada")
		print("Servidor creado. Esperando Jugador 2...")
		
		if not multiplayer.peer_connected.is_connected(_on_jugador_conectado):
			multiplayer.peer_connected.connect(_on_jugador_conectado)
		if not multiplayer.peer_disconnected.is_connected(_on_jugador_desconectado):
			multiplayer.peer_disconnected.connect(_on_jugador_desconectado)
	else:
		print("Error al crear servidor: ", error)

func unirse_a_servidor(ip_host: String):
	if ip_host == "":
		ip_host = "127.0.0.1"
	
	_limpiar_peer()
	
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip_host, PUERTO)
	
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Conectando a: ", ip_host)
		
		if not multiplayer.connected_to_server.is_connected(_on_conexion_exitosa):
			multiplayer.connected_to_server.connect(_on_conexion_exitosa)
		if not multiplayer.connection_failed.is_connected(_on_conexion_fallida_cb):
			multiplayer.connection_failed.connect(_on_conexion_fallida_cb)
		if not multiplayer.server_disconnected.is_connected(_on_servidor_desconectado_cb):
			multiplayer.server_disconnected.connect(_on_servidor_desconectado_cb)
	else:
		print("Error al iniciar cliente: ", error)

func _limpiar_peer():
	# Desconectar todas las señales del multiplayer
	if multiplayer.peer_connected.is_connected(_on_jugador_conectado):
		multiplayer.peer_connected.disconnect(_on_jugador_conectado)
	if multiplayer.peer_disconnected.is_connected(_on_jugador_desconectado):
		multiplayer.peer_disconnected.disconnect(_on_jugador_desconectado)
	if multiplayer.connected_to_server.is_connected(_on_conexion_exitosa):
		multiplayer.connected_to_server.disconnect(_on_conexion_exitosa)
	if multiplayer.connection_failed.is_connected(_on_conexion_fallida_cb):
		multiplayer.connection_failed.disconnect(_on_conexion_fallida_cb)
	if multiplayer.server_disconnected.is_connected(_on_servidor_desconectado_cb):
		multiplayer.server_disconnected.disconnect(_on_servidor_desconectado_cb)
	
	# Cerrar y destruir peer anterior
	if peer != null:
		peer.close()
		peer = null
	
	multiplayer.multiplayer_peer = null

# Función pública para consultar estado (usada en menu_principal)
func get_connection_status() -> int:
	if peer == null:
		return MultiplayerPeer.CONNECTION_DISCONNECTED
	return peer.get_connection_status()

# --- CALLBACKS ---
func _on_jugador_conectado(id):
	print("Jugador conectado! ID: ", id)
	emit_signal("jugador_conectado")

func _on_jugador_desconectado(id):
	print("Jugador desconectado. ID: ", id)
	emit_signal("servidor_desconectado")

func _on_conexion_exitosa():
	print("Conectado al Host!")
	emit_signal("jugador_conectado")

func _on_conexion_fallida_cb():
	print("No se pudo conectar.")
	emit_signal("conexion_fallida")

func _on_servidor_desconectado_cb():
	print("Host cerro la partida.")
	emit_signal("servidor_desconectado")
