extends Control

var menu_view: MenuView
var categoria_seleccionada = "ingles"

func _ready():
	menu_view = MenuView.new()
	menu_view.configurar(self)
	
	menu_view.configurar_fondo($FondoMenu)
	menu_view.crear_fondo_espacial()
	menu_view.crear_decoraciones()
	menu_view.configurar_titulo($Titulo, $Subtitulo)
	menu_view.configurar_botones_principales(
		$BotonJugar, $BotonSalir,
		Callable(self, "_on_jugar"),
		Callable(self, "_on_salir"),
		Callable(self, "_on_instrucciones"),
		Callable(self, "_on_info"),
		Callable(self, "_on_hover")
	)
	
	menu_view.crear_panel_instrucciones(Callable(self, "_on_cerrar_instrucciones"), Callable(self, "_on_hover"))
	menu_view.crear_panel_categorias(
		Callable(self, "_on_confirmar_categoria"),
		Callable(self, "_on_volver_menu"),
		Callable(self, "_on_hover"),
		Callable(self, "_on_categoria_seleccionada")
	)
	menu_view.crear_panel_creditos(Callable(self, "_on_hover"))
	menu_view.crear_panel_modo(
		Callable(self, "_on_modo_local"),
		Callable(self, "_on_modo_online"),
		Callable(self, "_on_hover")
	)
	menu_view.crear_panel_online(
		Callable(self, "_on_crear_partida"),
		Callable(self, "_on_unirse_partida"),
		Callable(self, "_on_volver_online"),
		Callable(self, "_on_hover")
	)
	
	if not Red.jugador_conectado.is_connected(_on_red_jugador_conectado):
		Red.jugador_conectado.connect(_on_red_jugador_conectado)
	if not Red.conexion_fallida.is_connected(_on_red_conexion_fallida):
		Red.conexion_fallida.connect(_on_red_conexion_fallida)
	
	_configurar_musica()
	Global.crear_boton_musica(self, _on_toggle_musica)
	var btn_musica = get_node_or_null("BotonMusica")
	Global.actualizar_boton_musica(btn_musica)

	menu_view.crear_boton_fullscreen(Callable(self, "_on_toggle_fullscreen"), Callable(self, "_on_hover"))
	# Agregar icono al botón fullscreen
	var btn_fs = get_node_or_null("BotonFullscreen")
	if btn_fs:
		var icono_fs = IconoFullscreen.new()
		icono_fs.name = "IconoFS"
		icono_fs.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn_fs.add_child(icono_fs)
	_actualizar_icono_fullscreen()
	
	menu_view.resaltar_categoria("ingles")
	
	if Global.abrir_categorias:
		Global.abrir_categorias = false
		menu_view.panel_categorias.show()
		if Global.es_multijugador and Global.mi_rol_multijugador == 2:
			menu_view.bloquear_categorias_cliente()

func _configurar_musica():
	$MusicaMenu.stream = preload("res://musica/menu_theme.wav")
	$MusicaMenu.volume_db = -13
	if Global.musica_activa:
		$MusicaMenu.play()
	$MusicaMenu.finished.connect(func(): $MusicaMenu.play())

func _actualizar_icono_fullscreen():
	var modo = DisplayServer.window_get_mode()
	var icono = get_node_or_null("BotonFullscreen/IconoFS")
	if icono:
		icono.actualizar_estado(modo == DisplayServer.WINDOW_MODE_FULLSCREEN or modo == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

# ====== EVENTOS ======
func _on_hover():
	$SonidoHover.stream = SFX.hover
	$SonidoHover.play()

func _on_jugar():
	menu_view.panel_modo.show()

func _on_instrucciones():
	menu_view.panel_instrucciones.show()

func _on_cerrar_instrucciones():
	menu_view.panel_instrucciones.hide()

func _on_info():
	menu_view.panel_creditos.show()

func _on_salir():
	get_tree().quit()

func _on_toggle_musica():
	Global.musica_activa = !Global.musica_activa
	var btn = get_node_or_null("BotonMusica")
	Global.actualizar_boton_musica(btn)
	if Global.musica_activa:
		if not $MusicaMenu.playing: $MusicaMenu.play()
	else:
		$MusicaMenu.stop()

func _on_toggle_fullscreen():
	var modo = DisplayServer.window_get_mode()
	var es_full = (modo == DisplayServer.WINDOW_MODE_FULLSCREEN or modo == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED if es_full else DisplayServer.WINDOW_MODE_FULLSCREEN)
	var icono = get_node_or_null("BotonFullscreen/IconoFS")
	if icono: icono.actualizar_estado(not es_full)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		_on_toggle_fullscreen()

# ====== CATEGORÍAS ======
func _on_categoria_seleccionada(clave):
	categoria_seleccionada = clave
	menu_view.resaltar_categoria(clave)
	menu_view.actualizar_label_categoria(clave)

func _on_confirmar_categoria():
	if Global.es_multijugador:
		rpc("rpc_iniciar_juego", categoria_seleccionada)
	else:
		Global.categoria = categoria_seleccionada
		get_tree().change_scene_to_file("res://juego_principal.tscn")

func _on_volver_menu():
	menu_view.panel_categorias.hide()

# ====== MODO DE JUEGO ======
func _on_modo_local():
	Global.es_multijugador = false
	menu_view.panel_modo.hide()
	menu_view.panel_categorias.show()

func _on_modo_online():
	menu_view.panel_modo.hide()
	menu_view.actualizar_estado_red("Esperando accion...", Color(0.7, 0.7, 0.7))
	menu_view.panel_online.show()

func _on_volver_online():
	NetworkHelper.desconectar()
	menu_view.panel_online.hide()
	menu_view.panel_modo.show()

# ====== RED ======
func _on_crear_partida():
	Global.es_multijugador = true
	Global.mi_rol_multijugador = 1
	menu_view.actualizar_estado_red("Creando sala...", Color(0.8, 0.8, 0.2))
	Red.crear_servidor()
	menu_view.actualizar_estado_red("Sala creada. Esperando al Jugador 2...", Color(0.8, 0.8, 0.2))

func _on_unirse_partida():
	Global.es_multijugador = true
	Global.mi_rol_multijugador = 2
	var ip = menu_view.obtener_ip()
	menu_view.actualizar_estado_red("Conectando a " + ip + "...", Color(0.2, 0.6, 1.0))
	Red.unirse_a_servidor(ip)

func _on_red_jugador_conectado():
	if Global.mi_rol_multijugador == 1:
		menu_view.actualizar_estado_red("¡Jugador 2 conectado! Elige la categoria...", Color(0.2, 1.0, 0.2))
		await get_tree().create_timer(1.5).timeout
		menu_view.panel_online.hide()
		menu_view.panel_categorias.show()
	else:
		menu_view.actualizar_estado_red("¡Conectado! Esperando a que el Host inicie...", Color(0.2, 1.0, 0.2))

func _on_red_conexion_fallida():
	menu_view.actualizar_estado_red("Error al conectar. Verifica la IP.", Color(1.0, 0.2, 0.2))

# ====== RPC ======
@rpc("any_peer", "call_local", "reliable")
func rpc_iniciar_juego(categoria_elegida):
	Global.categoria = categoria_elegida
	get_tree().change_scene_to_file("res://juego_principal.tscn")
