class_name TableroView
extends RefCounted

const TemaPixel = preload("res://efectos/tema_pixel.gd")
var ficha_escena = preload("res://ficha.tscn")

var tablero_visual: Node
var capa_ui: Node
var fichas_visuales = []

var preview_ficha = null
var preview_columna_actual = -1
var cursor_poder_label = null
var cursor_tipo_actual = ""
var fichas_resaltadas = []

var tablero_x := 311
var tablero_y := 145
var columnas := 7
var filas := 6
var tamano_celda := 70
var espacio := 5

var color_fondo_tablero := Color(0.08, 0.15, 0.4)
var color_celda_vacia := Color(0, 0, 0, 0)
var color_celda_congelada := Color(0.2, 0.6, 0.9, 0.5)
var color_fondo_pantalla := Color(0.05, 0.05, 0.08)
var color_seleccionable := Color(1.0, 0.3, 0.3, 0.4)

func configurar(
	_tablero_visual: Node,
	_capa_ui: Node,
	_columnas: int,
	_filas: int,
	_tamano_celda: int,
	_espacio: int
):
	tablero_visual = _tablero_visual
	capa_ui = _capa_ui
	columnas = _columnas
	filas = _filas
	tamano_celda = _tamano_celda
	espacio = _espacio

func celda_pos_x(columna: int) -> int:
	return tablero_x + espacio + columna * (tamano_celda + espacio)

func celda_pos_y(fila: int) -> int:
	return tablero_y + espacio + fila * (tamano_celda + espacio)

func dibujar_tablero():
	var fondo_pantalla = ColorRect.new()
	fondo_pantalla.name = "FondoPantalla"
	fondo_pantalla.size = Vector2(1152, 648)
	fondo_pantalla.color = color_fondo_pantalla
	fondo_pantalla.z_index = -20
	tablero_visual.add_child(fondo_pantalla)

	var FondoJuegoScript = preload("res://efectos/fondo_juego.gd")
	var fondo_juego = Node2D.new()
	fondo_juego.set_script(FondoJuegoScript)
	fondo_juego.z_index = -15
	tablero_visual.add_child(fondo_juego)

	var ancho_tablero = columnas * (tamano_celda + espacio) + espacio
	var alto_tablero = filas * (tamano_celda + espacio) + espacio

	var cristal_trasero = ColorRect.new()
	cristal_trasero.size = Vector2(ancho_tablero, alto_tablero)
	cristal_trasero.position = Vector2(tablero_x, tablero_y)
	cristal_trasero.color = Color(0.0, 0.02, 0.08, 0.65)
	cristal_trasero.z_index = 0
	tablero_visual.add_child(cristal_trasero)

	var fondo_tablero = Panel.new()
	fondo_tablero.name = "FondoTablero"
	fondo_tablero.size = Vector2(ancho_tablero + 16, alto_tablero + 16)
	fondo_tablero.position = Vector2(tablero_x - 8, tablero_y - 8)
	fondo_tablero.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0, 0, 0, 0),
		Color(0.2, 0.8, 1.0)
	))
	fondo_tablero.z_index = 10
	tablero_visual.add_child(fondo_tablero)

	for x in range(columnas):
		for y in range(filas):
			var celda = CeldaRedonda.new()
			celda.name = "Celda_" + str(x) + "_" + str(y)
			celda.size = Vector2(tamano_celda, tamano_celda)
			celda.position = Vector2(celda_pos_x(x), celda_pos_y(y))
			celda.color_celda = color_celda_vacia
			celda.color_tablero = color_fondo_tablero
			celda.z_index = 10
			tablero_visual.add_child(celda)

	for x in range(columnas):
		var flecha = Label.new()
		flecha.name = "Flecha_" + str(x)
		flecha.text = "▼"
		flecha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		flecha.position = Vector2(celda_pos_x(x) + 22, tablero_y - 30)
		TemaPixel.aplicar_fuente_label(flecha, 14)
		flecha.add_theme_color_override("font_color", Color(0.3, 0.9, 0.8, 0.8))
		tablero_visual.add_child(flecha)
	
	var label_inv_j1 = Label.new()
	label_inv_j1.position = Vector2(15, 160)
	label_inv_j1.size = Vector2(280, 80)
	TemaPixel.aplicar_fuente_label(label_inv_j1, 9)
	label_inv_j1.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	tablero_visual.add_child(label_inv_j1)

	var label_inv_j2 = Label.new()
	label_inv_j2.position = Vector2(15, 280)
	label_inv_j2.size = Vector2(280, 80)
	TemaPixel.aplicar_fuente_label(label_inv_j2, 9)
	label_inv_j2.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	tablero_visual.add_child(label_inv_j2)

	var ancho_tab = columnas * (tamano_celda + espacio) + espacio
	var alto_tab = filas * (tamano_celda + espacio) + espacio
	var label_turno_local = Label.new()
	label_turno_local.name = "EtiquetaTurno"
	label_turno_local.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_turno_local.position = Vector2(tablero_x, tablero_y + alto_tab + 15)
	label_turno_local.size = Vector2(ancho_tab, 30)
	TemaPixel.aplicar_fuente_label(label_turno_local, 11)
	label_turno_local.add_theme_color_override("font_color", Color(1, 1, 1))
	tablero_visual.add_child(label_turno_local)

	return {
		"label_inventario_j1": label_inv_j1,
		"label_inventario_j2": label_inv_j2,
		"label_turno": label_turno_local
	}

func agregar_overlay_hielo_celda(col: int, fila: int):
	var HieloScript = preload("res://efectos/hielo_overlay.gd")
	var overlay = Control.new()
	overlay.set_script(HieloScript)
	overlay.name = "HieloOverlay_" + str(col) + "_" + str(fila)
	overlay.size = Vector2(tamano_celda, tamano_celda)
	overlay.position = Vector2(celda_pos_x(col), celda_pos_y(fila))
	tablero_visual.add_child(overlay)

func quitar_overlays_hielo(col: int):
	for fila in range(filas):
		var overlay = tablero_visual.get_node_or_null("HieloOverlay_" + str(col) + "_" + str(fila))
		if overlay:
			overlay.queue_free()

func efecto_congelamiento(col: int):
	var CongelarScript = preload("res://efectos/congelamiento_efecto.gd")
	var efecto = Node2D.new()
	efecto.set_script(CongelarScript)
	var x = celda_pos_x(col)
	var y = celda_pos_y(0)
	var alto = filas * (tamano_celda + espacio)
	efecto.iniciar(x, y, tamano_celda, alto)
	tablero_visual.add_child(efecto)

func crear_explosion(centro: Vector2):
	var ExplosionScript = preload("res://efectos/explosion_pixel.gd")
	var explosion = Node2D.new()
	explosion.set_script(ExplosionScript)
	explosion.position = centro
	tablero_visual.add_child(explosion)

func animar_fichas_ganadoras(fichas_ganadoras: Array):
	for pos in fichas_ganadoras:
		if pos.x < 0 or pos.x >= fichas_visuales.size():
			continue
		
		if pos.y < 0 or pos.y >= fichas_visuales[pos.x].size():
			continue
		
		var ficha = fichas_visuales[pos.x][pos.y]
		if ficha != null:
			var tween = tablero_visual.create_tween().set_loops(8)
			tween.tween_property(ficha, "modulate:a", 0.2, 0.3)
			tween.tween_property(ficha, "modulate:a", 1.0, 0.3)

			var brillo = ColorRect.new()
			brillo.size = Vector2(tamano_celda + 6, tamano_celda + 6)
			brillo.position = Vector2(celda_pos_x(pos.x) - 3, celda_pos_y(pos.y) - 3)
			brillo.color = Color(1, 1, 1, 0.0)
			brillo.z_index = 9
			tablero_visual.add_child(brillo)

			var tween_brillo = tablero_visual.create_tween().set_loops(4)
			tween_brillo.tween_property(brillo, "color:a", 0.4, 0.4)
			tween_brillo.tween_property(brillo, "color:a", 0.0, 0.4)

			var tween_clean = tablero_visual.create_tween()
			tween_clean.tween_interval(4.0)
			tween_clean.tween_callback(brillo.queue_free)

func crear_preview_ficha(turno_actual: int, es_multijugador: bool, mi_rol_multijugador: int):
	if preview_ficha != null:
		preview_ficha.queue_free()
		preview_ficha = null
	
	preview_ficha = ficha_escena.instantiate()
	preview_ficha.size = Vector2(tamano_celda + 2, tamano_celda + 2)
	
	if not es_multijugador or turno_actual == mi_rol_multijugador:
		preview_ficha.configurar(turno_actual)
	else:
		var jugador_rival = 1 if mi_rol_multijugador == 2 else 2
		preview_ficha.configurar(jugador_rival)
	
	preview_ficha.modulate = Color(1, 1, 1, 0.5)
	preview_ficha.z_index = 10
	preview_ficha.visible = false
	tablero_visual.add_child(preview_ficha)
	preview_columna_actual = -1

func destruir_preview():
	if preview_ficha != null:
		preview_ficha.queue_free()
		preview_ficha = null
		preview_columna_actual = -1

func actualizar_preview(mouse_x: float, columnas_congeladas_info: Array, buscar_fila_callback: Callable):
	if preview_ficha == null:
		return
	
	var col = -1
	var ancho_tablero = columnas * (tamano_celda + espacio) + espacio
	
	if mouse_x >= tablero_x and mouse_x <= tablero_x + ancho_tablero:
		col = int((mouse_x - tablero_x - espacio) / float(tamano_celda + espacio))
		col = clamp(col, 0, columnas - 1)
	
	if col == -1:
		preview_ficha.visible = false
		preview_columna_actual = -1
		return
	
	if _esta_columna_congelada_local(col, columnas_congeladas_info) or buscar_fila_callback.call(col) == -1:
		preview_ficha.visible = false
		preview_columna_actual = -1
		return
	
	if col != preview_columna_actual:
		preview_columna_actual = col
		var pos_x = celda_pos_x(col) - 1
		var pos_y = tablero_y - tamano_celda - 10
		preview_ficha.position = Vector2(pos_x, pos_y)
	
	preview_ficha.modulate = Color(1, 1, 1, 0.5)
	preview_ficha.visible = true

func actualizar_cursor_poder(mouse_pos: Vector2, poder_a_usar: String):
	if cursor_poder_label == null or not is_instance_valid(cursor_poder_label):
		var script_path = ""
		match poder_a_usar:
			"BOMBA":
				script_path = "res://efectos/cursor_bomba.gd"
			"HIELO":
				script_path = "res://efectos/cursor_hielo.gd"
			_:
				return
		
		cursor_poder_label = Node2D.new()
		cursor_poder_label.set_script(load(script_path))
		cursor_poder_label.name = "CursorPoder"
		cursor_poder_label.z_index = 100
		capa_ui.add_child(cursor_poder_label)
	
	cursor_poder_label.position = mouse_pos
	cursor_poder_label.visible = true
	cursor_tipo_actual = poder_a_usar

func ocultar_cursor_poder():
	if cursor_poder_label != null and is_instance_valid(cursor_poder_label):
		cursor_poder_label.queue_free()
		cursor_poder_label = null
	cursor_tipo_actual = ""

func obtener_cursor_tipo_actual() -> String:
	return cursor_tipo_actual

func resaltar_posiciones(posiciones: Array):
	limpiar_resaltado()
	for pos in posiciones:
		var resaltado = ColorRect.new()
		resaltado.name = "Resaltado_" + str(pos.x) + "_" + str(pos.y)
		resaltado.size = Vector2(tamano_celda, tamano_celda)
		resaltado.position = Vector2(celda_pos_x(pos.x), celda_pos_y(pos.y))
		resaltado.color = color_seleccionable
		resaltado.z_index = 5
		tablero_visual.add_child(resaltado)
		fichas_resaltadas.append(resaltado)

func limpiar_resaltado():
	for r in fichas_resaltadas:
		if is_instance_valid(r):
			r.queue_free()
	fichas_resaltadas.clear()

func ocultar_todo_visual_temporal():
	if preview_ficha != null:
		preview_ficha.visible = false
	if cursor_poder_label != null:
		ocultar_cursor_poder()

func _esta_columna_congelada_local(columna: int, columnas_congeladas_info: Array) -> bool:
	for info in columnas_congeladas_info:
		if info["columna"] == columna:
			return true
	return false

func restaurar_columna_descongelada(col: int):
	for fila in range(filas):
		var celda = tablero_visual.get_node_or_null("Celda_" + str(col) + "_" + str(fila))
		if celda:
			celda.set_color(color_celda_vacia)
	quitar_overlays_hielo(col)
	var flecha = tablero_visual.get_node_or_null("Flecha_" + str(col))
	if flecha:
		flecha.text = "▼"
		flecha.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))

func aplicar_visual_hielo_en_columna(columna: int):
	for fila in range(filas):
		var celda = tablero_visual.get_node_or_null("Celda_" + str(columna) + "_" + str(fila))
		if celda:
			celda.set_color(color_celda_congelada)
		agregar_overlay_hielo_celda(columna, fila)
	var flecha = tablero_visual.get_node_or_null("Flecha_" + str(columna))
	if flecha:
		flecha.text = "❄️"
		flecha.add_theme_color_override("font_color", Color(0.3, 0.8, 1))

func mostrar_fantasma_rival(
	pos_rival: Vector2,
	poder_rival: String,
	mi_rol_multijugador: int,
	columnas_congeladas_info: Array,
	buscar_fila_callback: Callable
):
	if poder_rival == "NINGUNO":
		if cursor_poder_label != null:
			ocultar_cursor_poder()
		
		if preview_ficha == null:
			crear_preview_ficha(1 if mi_rol_multijugador == 2 else 2, true, mi_rol_multijugador)
		
		var jugador_rival = 1 if mi_rol_multijugador == 2 else 2
		preview_ficha.configurar(jugador_rival)
		preview_ficha.modulate = Color(1, 1, 1, 0.5)
		
		actualizar_preview(pos_rival.x, columnas_congeladas_info, buscar_fila_callback)
		preview_ficha.visible = true
	else:
		if preview_ficha != null:
			preview_ficha.visible = false
		
		if obtener_cursor_tipo_actual() != poder_rival:
			ocultar_cursor_poder()
		
		actualizar_cursor_poder(pos_rival, poder_rival)

func procesar_visual_local_lanzamiento(
	mouse_pos: Vector2,
	poder_seleccionado: String,
	turno_actual: int,
	es_multijugador: bool,
	mi_rol_multijugador: int,
	columnas_congeladas_info: Array,
	buscar_fila_callback: Callable
):
	if not es_multijugador or turno_actual == mi_rol_multijugador:
		if poder_seleccionado == "NINGUNO":
			if preview_ficha == null:
				crear_preview_ficha(turno_actual, es_multijugador, mi_rol_multijugador)
			actualizar_preview(mouse_pos.x, columnas_congeladas_info, buscar_fila_callback)
			preview_ficha.visible = true
			
			if cursor_poder_label != null:
				ocultar_cursor_poder()
		else:
			if preview_ficha != null:
				preview_ficha.visible = false
			
			if obtener_cursor_tipo_actual() != poder_seleccionado:
				ocultar_cursor_poder()
			
			actualizar_cursor_poder(mouse_pos, poder_seleccionado)

func crear_matriz_fichas_visuales():
	fichas_visuales.clear()
	for x in range(columnas):
		var col = []
		for y in range(filas):
			col.append(null)
		fichas_visuales.append(col)

func colocar_ficha_visual(col: int, fila: int, ficha_node):
	fichas_visuales[col][fila] = ficha_node

func obtener_ficha_visual(col: int, fila: int):
	return fichas_visuales[col][fila]

func eliminar_ficha_visual(col: int, fila: int):
	var ficha = fichas_visuales[col][fila]
	if ficha != null:
		ficha.queue_free()
		fichas_visuales[col][fila] = null
	return ficha

func mover_ficha_visual(col: int, desde_fila: int, hacia_fila: int):
	var ficha = fichas_visuales[col][desde_fila]
	fichas_visuales[col][hacia_fila] = ficha
	fichas_visuales[col][desde_fila] = null
	return ficha

func detectar_celda(mouse_pos: Vector2) -> Dictionary:
	var mx = mouse_pos.x
	var my = mouse_pos.y
	
	if my < 60:
		return {}
	
	var ancho_tablero = columnas * (tamano_celda + espacio) + espacio
	var alto_tablero = filas * (tamano_celda + espacio) + espacio
	
	if mx < tablero_x or mx > tablero_x + ancho_tablero:
		return {}
	if my < tablero_y or my > tablero_y + alto_tablero:
		return {}
	
	var col = int((mx - tablero_x - espacio) / float(tamano_celda + espacio))
	var fila = int((my - tablero_y - espacio) / float(tamano_celda + espacio))
	col = clamp(col, 0, columnas - 1)
	fila = clamp(fila, 0, filas - 1)
	
	return {"columna": col, "fila": fila}
