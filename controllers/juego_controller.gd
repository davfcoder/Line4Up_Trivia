extends Node2D

var ficha_escena = preload("res://ficha.tscn")

# ====== MODELOS ======
var board_model: BoardModel
var trivia_model: TriviaModel
var jugador1_model: PlayerModel
var jugador2_model: PlayerModel
var game_model: GameModel

# ====== VISTAS ======
var tablero_view: TableroView
var hud_view: HudView
var trivia_view: TriviaView
var pausa_view: PausaView
var resultado_view: ResultadoView
var sistema_ui_view: SistemaUIView

# ====== ESTADO ======
var juego_pausado = false
var poder_seleccionado = "NINGUNO"
var reproductor_tick: AudioStreamPlayer

# ====== CONSTANTES ======
const COLUMNAS = 7
const FILAS = 6
const TAMANO_CELDA = 70
const ESPACIO = 5

# ====== NODOS DE ESCENA ======
@onready var pantalla_pregunta = $CapaUI/PantallaPregunta
@onready var texto_pregunta = $CapaUI/PantallaPregunta/TextoPregunta
@onready var contenedor_botones = $CapaUI/PantallaPregunta/ContenedorBotones
@onready var texto_reloj = $CapaUI/PantallaPregunta/TextoReloj
@onready var temporizador = $Temporizador
@onready var tablero_visual = $TableroVisual
@onready var capa_ui = $CapaUI
@onready var sonido_ficha = $SonidoFicha
@onready var sonido_efectos = $SonidoEfectos
@onready var sonido_ui = $SonidoUI

# ====== SONIDO ======
func reproducir_ficha(fila):
	if SFX.ficha.has(fila):
		sonido_ficha.stream = SFX.ficha[fila]
		sonido_ficha.play()

func reproducir_efecto(sonido):
	sonido_efectos.stream = sonido
	sonido_efectos.play()

func reproducir_ui(sonido):
	sonido_ui.stream = sonido
	sonido_ui.play()

func obtener_jugador_actual() -> PlayerModel:
	return game_model.obtener_jugador_actual()

func obtener_jugador_por_id(id_jugador: int) -> PlayerModel:
	return game_model.obtener_jugador_por_id(id_jugador)

# ====== READY ======
func _ready():
	# Modelos
	board_model = BoardModel.new()
	trivia_model = TriviaModel.new()
	jugador1_model = PlayerModel.new(1)
	jugador2_model = PlayerModel.new(2)
	game_model = GameModel.new(board_model, trivia_model, jugador1_model, jugador2_model)
	
	# Vistas
	tablero_view = TableroView.new()
	hud_view = HudView.new()
	trivia_view = TriviaView.new()
	pausa_view = PausaView.new()
	resultado_view = ResultadoView.new()
	sistema_ui_view = SistemaUIView.new()
	
	# Tick
	reproductor_tick = AudioStreamPlayer.new()
	add_child(reproductor_tick)
	
	# Datos
	trivia_model.cargar_preguntas_desde_json("res://datos/preguntas.json", Global.categoria)
	board_model.crear_matriz_tablero()
	
	# Configurar vistas
	tablero_view.configurar(tablero_visual, capa_ui, COLUMNAS, FILAS, TAMANO_CELDA, ESPACIO)

	tablero_view.crear_matriz_fichas_visuales()
	
	hud_view.configurar(capa_ui, tablero_visual)
	trivia_view.configurar(pantalla_pregunta, texto_pregunta, contenedor_botones, texto_reloj)
	pausa_view.configurar(capa_ui)
	sistema_ui_view.configurar(capa_ui)
	resultado_view.configurar(pantalla_pregunta, texto_pregunta, texto_reloj, contenedor_botones, tablero_visual)

	# Dibujar
	var refs = tablero_view.dibujar_tablero()
	hud_view.enlazar_labels(refs["label_inventario_j1"], refs["label_inventario_j2"], refs["label_turno"])
	
	# UI
	hud_view.crear_interfaz_poderes(
		Callable(self, "_on_seleccionar_normal"),
		Callable(self, "_on_seleccionar_bomba"),
		Callable(self, "_on_seleccionar_hielo"),
		Callable(self, "_on_cancelar_poder"),
		Callable(self, "_on_reiniciar"),
		Callable(self, "_on_hover")
	)
	hud_view.crear_notificacion()
	hud_view.actualizar_inventario(jugador1_model, jugador2_model)
	conectar_botones_trivia()
	trivia_view.estilizar_pantalla_pregunta(Callable(self, "_aplicar_boton_pixel"))

	if not temporizador.timeout.is_connected(_on_tiempo_agotado):
		temporizador.timeout.connect(_on_tiempo_agotado)
	
	_configurar_musica()
	sistema_ui_view.crear_boton_musica(Callable(self, "_on_toggle_musica"))
	Global.actualizar_boton_musica(sistema_ui_view.obtener_boton_musica())
	sistema_ui_view.crear_boton_fullscreen(
		Callable(self, "_on_toggle_fullscreen"),
		Callable(self, "_on_hover")
	)
	_actualizar_icono_fullscreen()
	
	pausa_view.crear_menu_pausa(
		Callable(self, "_on_pausa_continuar"),
		Callable(self, "_on_pausa_reiniciar"),
		Callable(self, "_on_pausa_menu"),
		Callable(self, "toggle_pausa"),
		Callable(self, "_on_hover"),
		Callable(self, "_on_cambiar_categoria")
	)
	
	if Global.es_multijugador:
		if not Red.servidor_desconectado.is_connected(_on_rival_desconectado):
			Red.servidor_desconectado.connect(_on_rival_desconectado)
	
	_arrancar_juego()

func _configurar_musica():
	$MusicaJuego.stream = preload("res://musica/game_theme.wav")
	$MusicaJuego.volume_db = -12
	if Global.musica_activa:
		$MusicaJuego.play()
	if not $MusicaJuego.finished.is_connected(_on_musica_terminada):
		$MusicaJuego.finished.connect(_on_musica_terminada)

func _actualizar_icono_fullscreen():
	var modo = DisplayServer.window_get_mode()
	sistema_ui_view.actualizar_icono_fullscreen(
		modo == DisplayServer.WINDOW_MODE_FULLSCREEN or modo == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)

# ====== SINCRONIZACIÓN ======
func _arrancar_juego():
	if Global.es_multijugador:
		if multiplayer.is_server():
			_esperar_y_sincronizar()
	else:
		iniciar_turno()

func _esperar_y_sincronizar():
	await get_tree().create_timer(0.8).timeout
	rpc("rpc_sincronizar_inicio", game_model.turno_actual)
	iniciar_turno()

# ====== EVENTOS GLOBALES ======
func _on_hover():
	reproducir_ui(SFX.hover)

func _on_musica_terminada():
	$MusicaJuego.play()

func _on_toggle_musica():
	Global.musica_activa = !Global.musica_activa
	Global.actualizar_boton_musica(sistema_ui_view.obtener_boton_musica())
	if Global.musica_activa:
		if not $MusicaJuego.playing:
			$MusicaJuego.play()
	else:
		$MusicaJuego.stop()

func _on_toggle_fullscreen():
	var modo = DisplayServer.window_get_mode()
	var es_full = (modo == DisplayServer.WINDOW_MODE_FULLSCREEN or modo == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED if es_full else DisplayServer.WINDOW_MODE_FULLSCREEN)
	sistema_ui_view.actualizar_icono_fullscreen(not es_full)

func _aplicar_boton_pixel(boton, color_fondo, color_borde, tam: int = 11):
	hud_view.aplicar_boton_pixel_juego(boton, color_fondo, color_borde, tam)

# ====== PROCESS ======
func _process(_delta):
	if game_model.fase_juego == "PREGUNTA" and temporizador.time_left > 0:
		trivia_view.actualizar_reloj(temporizador.time_left, 20.0, reproductor_tick, SFX.tick)
	
	if game_model.fase_juego == "LANZAMIENTO" and not juego_pausado:
		var mouse_pos = get_viewport().get_mouse_position()
		tablero_view.procesar_visual_local_lanzamiento(
			mouse_pos, poder_seleccionado, game_model.turno_actual,
			Global.es_multijugador, Global.mi_rol_multijugador,
			board_model.columnas_congeladas_info,
			Callable(board_model, "buscar_fila_disponible")
		)
		if Global.es_multijugador and game_model.turno_actual == Global.mi_rol_multijugador:
			rpc("rpc_sync_mouse", mouse_pos, poder_seleccionado)
	else:
		tablero_view.ocultar_todo_visual_temporal()

# ====== INPUT ======
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_P:
				toggle_pausa()
				return
			KEY_F11:
				_on_toggle_fullscreen()
				return
	
	if juego_pausado or game_model.juego_terminado:
		return
	
	if not NetworkHelper.es_mi_turno(game_model.turno_actual):
		return
	
	if game_model.fase_juego == "LANZAMIENTO" and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _on_seleccionar_normal()
			KEY_2:
				if obtener_jugador_actual().tiene_bombas(): _on_seleccionar_bomba()
			KEY_3:
				if obtener_jugador_actual().tiene_hielos(): _on_seleccionar_hielo()
			KEY_ESCAPE: _on_cancelar_poder()
	
	if game_model.fase_juego != "LANZAMIENTO":
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var celda = tablero_view.detectar_celda(event.position)
		if not celda.is_empty():
			ejecutar_accion(celda["columna"], celda["fila"])

# ====== ACCIONES DE TABLERO ======
func ejecutar_accion(columna, fila):
	if Global.es_multijugador:
		rpc("rpc_ejecutar_tablero", poder_seleccionado, columna, fila)
	procesar_accion_tablero(poder_seleccionado, columna, fila)

func procesar_accion_tablero(poder, columna, fila):
	match poder:
		"NINGUNO":
			if board_model.esta_columna_congelada(columna): return
			lanzar_ficha(columna)
		"BOMBA":
			usar_bomba(columna, fila)
		"HIELO":
			if board_model.esta_columna_congelada(columna): return
			usar_hielo(columna)

# ====== TRIVIA ======
func conectar_botones_trivia():
	var botones = contenedor_botones.get_children()
	for i in range(botones.size()):
		botones[i].pressed.connect(_on_boton_trivia_presionado.bind(i))
		botones[i].mouse_entered.connect(_on_hover)

func iniciar_turno():
	if game_model.juego_terminado: return
	
	tablero_view.destruir_preview()
	tablero_view.ocultar_cursor_poder()
	
	if verificar_descongelamiento():
		if verificar_victoria_completa(): return
	
	hud_view.actualizar_opacidad_jugadores(game_model.turno_actual)
	game_model.fase_juego = GameModel.FASE_PREGUNTA
	pantalla_pregunta.show()
	hud_view.ocultar_botones_poder()
	hud_view.actualizar_label_turno(game_model.turno_actual)
	mostrar_pregunta_aleatoria()

func verificar_descongelamiento():
	var columnas_a_quitar = board_model.descongelar_columnas_de_turno(game_model.turno_actual)
	for info in columnas_a_quitar:
		tablero_view.restaurar_columna_descongelada(info["columna"])
	return columnas_a_quitar.size() > 0

func mostrar_pregunta_aleatoria():
	trivia_view.limpiar_botones_extra()
	trivia_view.preparar_visual_pregunta()
	trivia_view.resetear_reloj()
	
	if Global.es_multijugador and Global.mi_rol_multijugador == 2:
		trivia_view.mostrar_esperando_host()
		return
	
	var pregunta = trivia_model.obtener_pregunta_aleatoria()
	if pregunta.is_empty():
		trivia_view.mostrar_sin_preguntas()
		return
	
	if Global.es_multijugador:
		await get_tree().create_timer(0.3).timeout
		rpc("rpc_recibir_pregunta", pregunta)
	
	_aplicar_pregunta_visual()

func _aplicar_pregunta_visual():
	trivia_view.aplicar_pregunta_visual(
		game_model.turno_actual, Global.mi_rol_multijugador,
		Global.es_multijugador, trivia_model.pregunta_actual,
		Callable(self, "_aplicar_boton_pixel")
	)
	
	temporizador.stop()
	temporizador.start(20.0)

func _on_boton_trivia_presionado(indice):
	if game_model.fase_juego != GameModel.FASE_PREGUNTA: return
	if not NetworkHelper.es_mi_turno(game_model.turno_actual): return
	
	game_model.fase_juego = "PROCESANDO" # Bloqueo inmediato para evitar doble clic
	reproductor_tick.stop()
	temporizador.stop()
	
	var correcto = trivia_model.es_respuesta_correcta(indice)
	if Global.es_multijugador: rpc("rpc_resultado_pregunta", correcto)
	_procesar_resultado_pregunta(correcto)

func _on_tiempo_agotado():
	if game_model.fase_juego != GameModel.FASE_PREGUNTA: return
	if not NetworkHelper.es_mi_turno(game_model.turno_actual): return
	
	game_model.fase_juego = "PROCESANDO" # Bloqueo inmediato
	reproductor_tick.stop()
	
	if Global.es_multijugador: rpc("rpc_resultado_pregunta", false)
	_procesar_resultado_pregunta(false)

func _procesar_resultado_pregunta(fue_correcto):
	if fue_correcto:
		reproducir_efecto(SFX.correcto) 
		_manejar_acierto()
	else:
		reproducir_efecto(SFX.incorrecto)
		_manejar_fallo()

func _manejar_acierto():
	game_model.fase_juego = GameModel.FASE_LANZAMIENTO
	pantalla_pregunta.hide()
	
	var jugador = obtener_jugador_actual()
	jugador.registrar_acierto()
	
	if jugador.tiene_racha_para_poder():
		_otorgar_poder_aleatorio(game_model.turno_actual)
		jugador.consumir_racha_poder()
	
	hud_view.actualizar_inventario(jugador1_model, jugador2_model)
	_mostrar_botones_poder()

func _manejar_fallo():
	game_model.fase_juego = "ERROR_MOSTRADO"
	obtener_jugador_actual().registrar_fallo()
	_mostrar_mensaje_error()

func _mostrar_mensaje_error():
	trivia_view.mostrar_mensaje_error(
		trivia_model.obtener_respuesta_correcta_texto(),
		game_model.turno_actual, Global.mi_rol_multijugador,
		Global.es_multijugador,
		Callable(self, "_on_continuar_despues_error"),
		Callable(self, "_on_hover"),
		Callable(self, "_aplicar_boton_pixel")
	)
	
	# Solo el jugador de este turno inicia el contador automático de 5s.
	if not Global.es_multijugador or NetworkHelper.es_mi_turno(game_model.turno_actual):
		var btn = pantalla_pregunta.get_node_or_null("BotonContinuar")
		if btn:
			# Pasamos el ID único del botón para evitar cruces con turnos futuros
			get_tree().create_timer(5.0).timeout.connect(_auto_continuar.bind(btn.get_instance_id()))

func _auto_continuar(btn_id: int):
	if game_model.fase_juego == "ERROR_MOSTRADO":
		var btn_actual = pantalla_pregunta.get_node_or_null("BotonContinuar")
		# Solo avanza si el botón en pantalla es EXACTAMENTE el mismo que creó este temporizador
		if btn_actual and btn_actual.get_instance_id() == btn_id:
			_on_continuar_despues_error(btn_actual)

func _on_continuar_despues_error(boton):
	if game_model.fase_juego != "ERROR_MOSTRADO": return
	game_model.fase_juego = "CAMBIANDO_TURNO"
	
	# Solo el dueño del turno avisa al otro que ya se acabó el tiempo de espera
	if Global.es_multijugador and NetworkHelper.es_mi_turno(game_model.turno_actual):
		rpc("rpc_continuar_error")
		
	_procesar_continuar_error(boton)

func _procesar_continuar_error(boton):
	if boton and is_instance_valid(boton): boton.queue_free()
	cambiar_turno()

func _otorgar_poder_aleatorio(jugador):
	if not NetworkHelper.es_mi_turno(game_model.turno_actual): return
	var poder = ["BOMBA", "HIELO"].pick_random()
	if Global.es_multijugador: rpc("rpc_recibir_poder", jugador, poder)
	_aplicar_poder_ganado(jugador, poder)

func _aplicar_poder_ganado(jugador, poder):
	obtener_jugador_por_id(jugador).otorgar_poder(poder)
	var icono_poder = "BOMBA" if poder == "BOMBA" else "HIELO"
	var icono_jugador = "P1" if jugador == 1 else "P2"
	hud_view.mostrar_notificacion(icono_jugador + " ¡Jugador " + str(jugador) + " gano " + icono_poder + "!")
	hud_view.actualizar_inventario(jugador1_model, jugador2_model)
	_mostrar_botones_poder()

# ====== PODERES ======
func _mostrar_botones_poder():
	hud_view.mostrar_botones_poder(
		Global.es_multijugador, game_model.turno_actual,
		Global.mi_rol_multijugador, obtener_jugador_actual()
	)
	poder_seleccionado = "NINGUNO"

func _on_seleccionar_normal():
	poder_seleccionado = "NINGUNO"
	hud_view.mostrar_modo_normal()
	tablero_view.limpiar_resaltado()
	reproducir_ui(SFX.ficha_seleccionada)

func _on_seleccionar_bomba():
	poder_seleccionado = "BOMBA"
	hud_view.mostrar_modo_bomba()
	tablero_view.resaltar_posiciones(board_model.obtener_posiciones_enemigas(game_model.turno_actual))
	reproducir_ui(SFX.bomba_seleccionada)

func _on_seleccionar_hielo():
	poder_seleccionado = "HIELO"
	hud_view.mostrar_modo_hielo()
	tablero_view.limpiar_resaltado()
	reproducir_ui(SFX.hielo_seleccionado)

func _on_cancelar_poder():
	_on_seleccionar_normal()

# ====== LANZAR FICHA ======
func lanzar_ficha(columna):
	var fila = board_model.colocar_ficha(columna, game_model.turno_actual)
	if fila == -1: return
	
	game_model.fase_juego = GameModel.FASE_ANIMANDO
	tablero_view.destruir_preview()
	
	var nueva_ficha = ficha_escena.instantiate()
	nueva_ficha.z_index = 5
	nueva_ficha.position = Vector2(tablero_view.celda_pos_x(columna) - 1, tablero_view.tablero_y - TAMANO_CELDA)
	nueva_ficha.size = Vector2(TAMANO_CELDA + 2, TAMANO_CELDA + 2)
	nueva_ficha.configurar(game_model.turno_actual)
	tablero_visual.add_child(nueva_ficha)
	
	tablero_view.colocar_ficha_visual(columna, fila, nueva_ficha)
	nueva_ficha.animar_caida(tablero_view.celda_pos_y(fila) - 1)
	reproducir_ficha(fila)
	hud_view.ocultar_botones_poder()
	
	await get_tree().create_timer(0.6).timeout
	
	if board_model.verificar_victoria(columna, fila, game_model.turno_actual):
		game_model.juego_terminado = true
		game_model.fase_juego = GameModel.FASE_FIN
		_mostrar_victoria()
		return
	
	if board_model.tablero_lleno():
		game_model.juego_terminado = true
		game_model.fase_juego = GameModel.FASE_FIN
		_mostrar_empate()
		return
	
	cambiar_turno()

# ====== BOMBA ======
func usar_bomba(columna, fila):
	var resultado = board_model.usar_bomba(game_model.turno_actual, columna, fila)
	
	match resultado["motivo"]:
		"COLUMNA_CONGELADA":
			hud_view.mostrar_notificacion("❄️ ¡Columna congelada! No puedes usar bomba ahí")
			return
		"CELDA_VACIA":
			hud_view.mostrar_notificacion("[!] Casilla vacia! Elige una ficha enemiga")
			return
		"FICHA_PROPIA":
			hud_view.mostrar_notificacion("[!] Esa ficha es tuya! Elige una enemiga")
			return
		"NO_ES_ENEMIGA":
			return
	
	game_model.fase_juego = GameModel.FASE_ANIMANDO
	tablero_view.destruir_preview()
	tablero_view.ocultar_cursor_poder()
	
	var ficha = tablero_view.obtener_ficha_visual(columna, fila)
	if ficha != null:
		tablero_view.crear_explosion(ficha.position + Vector2(float(TAMANO_CELDA / 2.0), float(TAMANO_CELDA / 2.0)))
		reproducir_efecto(SFX.explosion)
		tablero_view.eliminar_ficha_visual(columna, fila)
	
	obtener_jugador_actual().usar_bomba()
	tablero_view.limpiar_resaltado()
	hud_view.actualizar_inventario(jugador1_model, jugador2_model)
	hud_view.ocultar_botones_poder()
	
	await get_tree().create_timer(0.3).timeout
	await _aplicar_gravedad(columna)
	
	await get_tree().create_timer(0.3).timeout
	if verificar_victoria_completa(): return
	cambiar_turno()

# ====== HIELO ======
func usar_hielo(columna):
	var resultado = board_model.usar_hielo(game_model.turno_actual, columna)
	if not resultado["ok"]: return
	
	obtener_jugador_actual().usar_hielo()
	tablero_view.aplicar_visual_hielo_en_columna(columna)
	tablero_view.efecto_congelamiento(columna)
	hud_view.actualizar_inventario(jugador1_model, jugador2_model)
	reproducir_efecto(SFX.congelado)
	tablero_view.ocultar_cursor_poder()
	
	poder_seleccionado = "NINGUNO"
	hud_view.mostrar_modo_lanzar_ficha()
	hud_view.deshabilitar_botones_poder()

# ====== GRAVEDAD ======
func _aplicar_gravedad(columna):
	while true:
		var movimientos = board_model.aplicar_gravedad_logica(columna)
		if movimientos.is_empty(): break
		
		for mov in movimientos:
			var ficha = tablero_view.mover_ficha_visual(columna, mov["desde_fila"], mov["hacia_fila"])
			if ficha != null:
				var tween = create_tween()
				tween.tween_property(ficha, "position:y", tablero_view.celda_pos_y(mov["hacia_fila"]) - 1, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		await get_tree().create_timer(0.25).timeout

func verificar_victoria_completa():
	var resultado = board_model.verificar_victoria_completa(game_model.turno_actual)
	if resultado["hay_victoria"]:
		game_model.turno_actual = resultado["ganador"]
		game_model.juego_terminado = true
		game_model.fase_juego = GameModel.FASE_FIN
		_mostrar_victoria()
		return true
	return false

# ====== RESULTADOS ======
func _ocultar_ui_fin():
	tablero_view.destruir_preview()
	tablero_view.ocultar_cursor_poder()
	hud_view.ocultar_botones_poder()
	pausa_view.ocultar_boton_pausa()
	sistema_ui_view.ocultar_boton_musica()
	sistema_ui_view.ocultar_boton_fullscreen()
	# Limpiar el overlay de espera si estaba activo
	var overlay = pantalla_pregunta.get_node_or_null("OverlayEspera")
	if overlay: overlay.hide()

func _mostrar_victoria():
	_ocultar_ui_fin()
	
	tablero_view.animar_fichas_ganadoras(board_model.fichas_ganadoras)
	reproducir_efecto(SFX.victoria)
	
	var VictoriaScript = preload("res://efectos/victoria_efecto.gd")
	var efecto = Node2D.new()
	efecto.set_script(VictoriaScript)
	tablero_visual.add_child(efecto)
	
	var jugador_txt = "P1 ROJO" if game_model.turno_actual == 1 else "P2 AMARILLO"
	var color_texto = Color(1, 0.3, 0.3) if game_model.turno_actual == 1 else Color(1, 0.85, 0.1)
	resultado_view.crear_texto_resultado_superior(jugador_txt + " GANA!", color_texto)
	
	await get_tree().create_timer(3.0).timeout
	
	resultado_view.aplicar_estilo_victoria(game_model.turno_actual)
	hud_view.boton_reiniciar.hide()
	resultado_view.mostrar_panel_victoria(
		game_model.turno_actual, Global.es_multijugador, Global.mi_rol_multijugador,
		Callable(self, "_on_reiniciar"), Callable(self, "_on_ir_menu_principal"),
		Callable(self, "_on_hover"), Callable(self, "_aplicar_boton_pixel"),
		Callable(self, "_on_cambiar_categoria")
	)

func _mostrar_empate():
	_ocultar_ui_fin()
	
	reproducir_efecto(SFX.empate)
	resultado_view.crear_texto_resultado_superior("EMPATE!", Color(0.7, 0.7, 0.8))
	
	await get_tree().create_timer(2.0).timeout
	
	resultado_view.aplicar_estilo_empate()
	hud_view.boton_reiniciar.hide()
	resultado_view.mostrar_panel_empate(
		Callable(self, "_on_reiniciar"), Callable(self, "_on_ir_menu_principal"),
		Callable(self, "_on_hover"), Callable(self, "_aplicar_boton_pixel"),
		Callable(self, "_on_cambiar_categoria")
	)

# ====== NAVEGACIÓN ======
var procesando_salida = false

func _on_reiniciar():
	if procesando_salida: return
	
	if Global.es_multijugador:
		sistema_ui_view.mostrar_popup_aviso("Esperando respuesta del rival...")
		rpc("rpc_solicitar_revancha")
	else:
		procesando_salida = true
		_procesar_cambio_escena("res://juego_principal.tscn", true)

func _on_ir_menu_principal():
	# Si presionan ir al menú, actuamos como abandono para avisar al rival
	_salir_y_avisar()

func _salir_y_avisar():
	if procesando_salida: return
	procesando_salida = true
	
	if Global.es_multijugador:
		rpc("rpc_rival_abandono")
		await get_tree().create_timer(0.1).timeout
	_procesar_cambio_escena("res://menu_principal.tscn", false)

func _procesar_cambio_escena(ruta, abrir_cat):
	get_tree().paused = false
	Global.reproducir_transicion(SFX.retirar_fichas)
	Global.abrir_categorias = abrir_cat
	if not abrir_cat and Global.es_multijugador:
		NetworkHelper.desconectar()
	get_tree().change_scene_to_file(ruta)

func _on_cambiar_categoria():
	if procesando_salida: return
	
	if Global.es_multijugador:
		juego_pausado = false
		pausa_view.ocultar_panel()
		_pausar_tiempo_red(true)
		sistema_ui_view.mostrar_popup_aviso("Esperando a que el rival acepte cambiar categoria...")
		rpc("rpc_solicitar_cambio_categoria")
	else:
		procesando_salida = true
		_procesar_cambio_escena("res://menu_principal.tscn", true) # True = Abre el selector para ambos

func _on_rival_desconectado():
	Global.es_multijugador = false
	
	if is_inside_tree():
		reproducir_ui(SFX.incorrecto)
		
		# Si el juego ya había terminado (pantalla de victoria/empate)
		if game_model.juego_terminado:
			sistema_ui_view.mostrar_popup_aviso("El rival ha abandonado la sala.\nVolviendo al menu principal...")
		# Si el juego se interrumpió a la mitad
		else:
			game_model.juego_terminado = true
			if pantalla_pregunta: pantalla_pregunta.hide()
			hud_view.mostrar_notificacion("¡EL RIVAL SE HA DESCONECTADO!")
			
		await get_tree().create_timer(3.0).timeout
		
		if is_inside_tree():
			procesando_salida = true
			# CAMBIO: Usamos _procesar_cambio_escena con 'false' para forzar que vaya al menú y limpie variables
			_procesar_cambio_escena("res://menu_principal.tscn", false)

func cambiar_turno():
	game_model.cambiar_turno()
	iniciar_turno()

# ====== PAUSA ======
func toggle_pausa():
	if game_model.juego_terminado: return
	juego_pausado = !juego_pausado
	if juego_pausado:
		pausa_view.mostrar_panel()
		if not Global.es_multijugador: get_tree().paused = true
	else:
		pausa_view.ocultar_panel()
		get_tree().paused = false

func _on_pausa_continuar():
	juego_pausado = false
	pausa_view.ocultar_panel()
	get_tree().paused = false

# ====== PAUSA ======
func _on_pausa_reiniciar():
	if Global.es_multijugador:
		juego_pausado = false
		pausa_view.ocultar_panel()
		_pausar_tiempo_red(true)
		sistema_ui_view.mostrar_popup_aviso("Esperando a que el rival acepte el reinicio...")
		rpc("rpc_solicitar_reinicio")
	else:
		juego_pausado = false
		pausa_view.ocultar_panel()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://juego_principal.tscn")

func _pausar_tiempo_red(pausar: bool):
	temporizador.paused = pausar
	if is_instance_valid(reproductor_tick):
		reproductor_tick.stream_paused = pausar

func _on_pausa_menu():
	juego_pausado = false
	get_tree().paused = false
	_salir_y_avisar()

# ====== RPCs ======
@rpc("authority", "call_remote", "reliable")
func rpc_sincronizar_inicio(turno): game_model.turno_actual = turno; iniciar_turno()

@rpc("any_peer", "call_remote", "reliable")
func rpc_ejecutar_tablero(poder, col, fil):
	tablero_view.ocultar_todo_visual_temporal()
	poder_seleccionado = poder
	procesar_accion_tablero(poder, col, fil)

@rpc("any_peer", "call_remote", "reliable")
func rpc_recibir_pregunta(pregunta):
	trivia_model.establecer_pregunta_actual(pregunta)
	_aplicar_pregunta_visual()

@rpc("any_peer", "call_remote", "reliable")
func rpc_resultado_pregunta(correcto):
	game_model.fase_juego = "PROCESANDO"
	reproductor_tick.stop()
	temporizador.stop()
	_procesar_resultado_pregunta(correcto)

@rpc("any_peer", "call_remote", "reliable")
func rpc_recibir_poder(jugador, poder): _aplicar_poder_ganado(jugador, poder)

@rpc("any_peer", "call_remote", "reliable")
func rpc_continuar_error():
	if game_model.fase_juego != "ERROR_MOSTRADO": return
	game_model.fase_juego = "CAMBIANDO_TURNO"
	var btn = pantalla_pregunta.get_node_or_null("BotonContinuar")
	_procesar_continuar_error(btn)

@rpc("any_peer", "call_remote", "reliable")
func rpc_rival_abandono(): _on_rival_desconectado()

@rpc("any_peer", "call_remote", "reliable")
func rpc_cambiar_escena(ruta, abrir_cat): 
	if procesando_salida: return
	procesando_salida = true
	_procesar_cambio_escena(ruta, abrir_cat)

@rpc("any_peer", "call_remote", "unreliable")
func rpc_sync_mouse(pos, poder):
	if game_model.fase_juego != "LANZAMIENTO": return
	hud_view.mostrar_modo_rival(poder)
	tablero_view.mostrar_fantasma_rival(
		pos, poder, Global.mi_rol_multijugador,
		board_model.columnas_congeladas_info,
		Callable(board_model, "buscar_fila_disponible")
	)

# --- REVANCHA AL FINAL DEL JUEGO ---
@rpc("any_peer", "call_remote", "reliable")
func rpc_solicitar_revancha():
	sistema_ui_view.mostrar_popup_pregunta(
		"El rival quiere jugar de nuevo.\n¿Aceptas?", 
		Callable(self, "_responder_revancha").bind(true), 
		Callable(self, "_responder_revancha").bind(false),
		Callable(self, "_aplicar_boton_pixel")
	)

func _responder_revancha(acepta: bool):
	sistema_ui_view.cerrar_popups()
	rpc("rpc_respuesta_revancha", acepta)
	
	if acepta:
		procesando_salida = true
		_procesar_cambio_escena("res://juego_principal.tscn", true)
	else:
		procesando_salida = true
		# Damos una fracción de segundo para asegurar que el RPC viaje por la red antes de desconectar
		await get_tree().create_timer(0.1).timeout 
		_procesar_cambio_escena("res://menu_principal.tscn", false)

@rpc("any_peer", "call_remote", "reliable")
func rpc_respuesta_revancha(acepta: bool):
	sistema_ui_view.cerrar_popups()
	if acepta:
		procesando_salida = true
		_procesar_cambio_escena("res://juego_principal.tscn", true)
	else:
		sistema_ui_view.mostrar_popup_aviso("El rival rechazo jugar de nuevo.\nSaliendo al menu...")
		await get_tree().create_timer(3.0).timeout
		procesando_salida = true
		_procesar_cambio_escena("res://menu_principal.tscn", false)


# --- REINICIO EN MEDIO DEL JUEGO (PAUSA) ---
@rpc("any_peer", "call_remote", "reliable")
func rpc_solicitar_reinicio():
	_pausar_tiempo_red(true)
	sistema_ui_view.mostrar_popup_pregunta(
		"El rival quiere reiniciar la partida actual.\n¿Aceptas?", 
		Callable(self, "_responder_reinicio").bind(true), 
		Callable(self, "_responder_reinicio").bind(false),
		Callable(self, "_aplicar_boton_pixel")
	)

func _responder_reinicio(acepta: bool):
	sistema_ui_view.cerrar_popups()
	rpc("rpc_respuesta_reinicio", acepta)
	if acepta:
		procesando_salida = true
		_procesar_cambio_escena("res://juego_principal.tscn", true)
	else:
		_pausar_tiempo_red(false) # Retoma el tiempo normal

@rpc("any_peer", "call_remote", "reliable")
func rpc_respuesta_reinicio(acepta: bool):
	sistema_ui_view.cerrar_popups()
	if acepta:
		procesando_salida = true
		_procesar_cambio_escena("res://juego_principal.tscn", true)
	else:
		sistema_ui_view.mostrar_popup_aviso("El rival rechazo el reinicio.")
		await get_tree().create_timer(2.0).timeout
		sistema_ui_view.cerrar_popups()
		_pausar_tiempo_red(false) # Retoma el tiempo normal

# --- CAMBIO DE CATEGORÍA ---
@rpc("any_peer", "call_remote", "reliable")
func rpc_solicitar_cambio_categoria():
	_pausar_tiempo_red(true)
	sistema_ui_view.mostrar_popup_pregunta(
		"El rival quiere cambiar de categoria.\n¿Aceptas?", 
		Callable(self, "_responder_cambio_categoria").bind(true), 
		Callable(self, "_responder_cambio_categoria").bind(false),
		Callable(self, "_aplicar_boton_pixel")
	)

func _responder_cambio_categoria(acepta: bool):
	sistema_ui_view.cerrar_popups()
	rpc("rpc_respuesta_cambio_categoria", acepta)
	if acepta:
		procesando_salida = true
		_procesar_cambio_escena("res://menu_principal.tscn", true)
	else:
		_pausar_tiempo_red(false) # Retoma el tiempo

@rpc("any_peer", "call_remote", "reliable")
func rpc_respuesta_cambio_categoria(acepta: bool):
	sistema_ui_view.cerrar_popups()
	if acepta:
		procesando_salida = true
		_procesar_cambio_escena("res://menu_principal.tscn", true)
	else:
		sistema_ui_view.mostrar_popup_aviso("El rival rechazo cambiar de categoria.")
		await get_tree().create_timer(2.0).timeout
		sistema_ui_view.cerrar_popups()
		_pausar_tiempo_red(false)
