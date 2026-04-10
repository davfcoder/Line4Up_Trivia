extends Control

const TemaPixel = preload("res://efectos/tema_pixel.gd")

var menu_view: MenuView
var categoria_seleccionada = "ingles"
var custom_cat_view: CustomCategoryView
var preguntas_custom = []
var nombre_categoria_editando = ""
var preguntas_importadas_pendientes = []

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
	menu_view.colocar_boton_volver_lateral(menu_view.panel_categorias)

	menu_view.crear_panel_creditos(Callable(self, "_on_cerrar_creditos"), Callable(self, "_on_hover"))
	menu_view.crear_panel_modo(
		Callable(self, "_on_modo_local"),
		Callable(self, "_on_modo_online"),
		Callable(self, "_on_volver_menu"),
		Callable(self, "_on_hover")
	)
	menu_view.crear_panel_online(
		Callable(self, "_on_crear_partida"),
		Callable(self, "_on_unirse_partida"),
		Callable(self, "_on_volver_online"),
		Callable(self, "_on_hover")
	)
	
	custom_cat_view = CustomCategoryView.new()
	custom_cat_view.configurar(self)
	custom_cat_view.crear_panel_editor(
		Callable(self, "_on_agregar_pregunta_custom"),
		Callable(self, "_on_guardar_categoria_custom"),
		Callable(self, "_on_importar_categoria"),
		Callable(self, "_on_exportar_plantilla_categoria"),
		Callable(self, "_on_volver_editor_custom"),
		Callable(self, "_on_eliminar_pregunta_custom"),
		Callable(self, "_on_hover")
	)
	
	if not Red.jugador_conectado.is_connected(_on_red_jugador_conectado):
		Red.jugador_conectado.connect(_on_red_jugador_conectado)
	if not Red.conexion_fallida.is_connected(_on_red_conexion_fallida):
		Red.conexion_fallida.connect(_on_red_conexion_fallida)
	
	_configurar_musica()
	Global.crear_boton_musica(self, _on_toggle_musica)

	var viejo_fs = get_node_or_null("BotonFullscreen")
	if viejo_fs:
		viejo_fs.queue_free()
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
	
	for child in get_children():
		if child.name.begins_with("@"):
			print("Nodo anonimo sospechoso: ", child.name, " - ", child)
	
	menu_view.resaltar_categoria("ingles")
	
	# ... (Casi al final del _ready en menu_controller)
	if Global.abrir_categorias:
		Global.abrir_categorias = false
		_mostrar_solo_panel(menu_view.panel_categorias)

		var btn_info = get_node_or_null("BtnInfo")
		if btn_musica: btn_musica.hide()
		if btn_fs: btn_fs.hide()
		if btn_info: btn_info.hide()
		
		if Global.es_multijugador:
			if Global.mi_rol_multijugador == 2:
				menu_view.bloquear_categorias_cliente()
			# Transformar el botón a < MENU
			_actualizar_textos_volver("< MENU")

func _cazar_mancha_negra():
	for child in get_children():
		# Si es un ColorRect o Panel, está en la esquina (0,0), es pequeño y NO es FondoMenu
		if (child is ColorRect or child is Panel) and child.name != "FondoMenu":
			if child.position == Vector2.ZERO and child.size.x <= 100 and child.size.y <= 100:
				child.queue_free() # Destrucción total

func _on_cerrar_creditos():
	_mostrar_solo_panel(null)

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
	_mostrar_solo_panel(menu_view.panel_modo)

func _on_instrucciones():
	_mostrar_solo_panel(menu_view.panel_instrucciones)

func _on_cerrar_instrucciones():
	_mostrar_solo_panel(null)

func _on_info():
	_mostrar_solo_panel(menu_view.panel_creditos)

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
# ====== CATEGORÍA PERSONALIZADA ======
func _on_categoria_seleccionada(clave):
	if clave == "personalizada":
		_abrir_selector_personalizada()
		return
	categoria_seleccionada = clave
	menu_view.resaltar_categoria(clave)
	menu_view.actualizar_label_categoria(clave)

func _abrir_selector_personalizada():
	var guardadas = CustomCategoryModel.obtener_categorias_guardadas()
	var btn_musica = get_node_or_null("BotonMusica")
	var btn_fs = get_node_or_null("BotonFullscreen")
	if btn_musica: btn_musica.hide()
	if btn_fs: btn_fs.hide()
	if guardadas.is_empty():
		preguntas_custom.clear()
		nombre_categoria_editando = ""
		custom_cat_view.resetear_editor()
		custom_cat_view.establecer_modo_nueva()
		_mostrar_solo_panel(custom_cat_view.panel_editor)
	else:
		_mostrar_selector_custom(guardadas)

func _mostrar_selector_custom(guardadas: Array):
	menu_view.panel_categorias.hide()
	var btn_musica = get_node_or_null("BotonMusica")
	var btn_fs = get_node_or_null("BotonFullscreen")
	if btn_musica: btn_musica.hide()
	if btn_fs: btn_fs.hide()
	
	var panel_sel = Control.new()
	panel_sel.name = "PanelSelCustom"
	panel_sel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_sel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel_sel.z_index = 200
	add_child(panel_sel)
	
	var fondo = ColorRect.new()
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.color = Color(0, 0, 0, 0.92)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	panel_sel.add_child(fondo)
	
	var ventana = Panel.new()
	ventana.position = Vector2(276, 60)
	ventana.size = Vector2(600, 520)
	ventana.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.05, 0.05, 0.16, 0.98), Color(0.7, 0.5, 0.15)
	))
	panel_sel.add_child(ventana)
	
	var titulo = Label.new()
	titulo.text = "CATEGORIAS PERSONALIZADAS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(0, 18)
	titulo.size = Vector2(600, 30)
	TemaPixel.aplicar_fuente_label(titulo, 14)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ventana.add_child(titulo)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(40, 70)
	scroll.size = Vector2(520, 250)
	ventana.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	
	for nombre in guardadas:
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(500, 42)
		
		var btn_usar = Button.new()
		btn_usar.text = _texto_corto(nombre.to_upper(), 24)
		btn_usar.tooltip_text = nombre
		btn_usar.custom_minimum_size = Vector2(300, 38)
		btn_usar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_usar.clip_text = true
		btn_usar.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		menu_view.aplicar_boton_pixel(btn_usar, Color(0.08, 0.08, 0.2), Color(0.2, 0.3, 0.6), 10)
		btn_usar.pressed.connect(func():
			categoria_seleccionada = "custom_" + nombre
			menu_view.resaltar_categoria("personalizada")
			menu_view.actualizar_label_categoria("custom_" + nombre)
			panel_sel.queue_free()
			_mostrar_solo_panel(menu_view.panel_categorias)
		)
		btn_usar.mouse_entered.connect(_on_hover)
		hbox.add_child(btn_usar)
		
		var btn_editar = Button.new()
		btn_editar.text = "EDITAR"
		btn_editar.custom_minimum_size = Vector2(110, 38)
		menu_view.aplicar_boton_pixel(btn_editar, Color(0.15, 0.2, 0.35), Color(0.4, 0.6, 0.9), 9)
		btn_editar.pressed.connect(func():
			panel_sel.queue_free()
			_editar_categoria_custom(nombre)
		)
		btn_editar.mouse_entered.connect(_on_hover)
		hbox.add_child(btn_editar)
		
		var btn_borrar = Button.new()
		btn_borrar.text = "X"
		btn_borrar.custom_minimum_size = Vector2(40, 38)
		menu_view.aplicar_boton_pixel(btn_borrar, Color(0.35, 0.06, 0.06), Color(0.8, 0.2, 0.2), 11)
		btn_borrar.pressed.connect(func():
			_mostrar_confirmacion_borrar_categoria(nombre, panel_sel)
		)
		btn_borrar.mouse_entered.connect(_on_hover)
		hbox.add_child(btn_borrar)
		
		vbox.add_child(hbox)
	
	var btn_crear = Button.new()
	btn_crear.text = "+ CREAR NUEVA"
	btn_crear.position = Vector2(150, 350)
	btn_crear.size = Vector2(300, 45)
	menu_view.aplicar_boton_pixel(btn_crear, Color(0.06, 0.35, 0.12), Color(0.15, 0.8, 0.3), 12)
	btn_crear.pressed.connect(func():
		panel_sel.queue_free()
		preguntas_custom.clear()
		nombre_categoria_editando = ""
		custom_cat_view.resetear_editor()
		custom_cat_view.establecer_modo_nueva()
		_mostrar_solo_panel(custom_cat_view.panel_editor)
	)
	btn_crear.mouse_entered.connect(_on_hover)
	ventana.add_child(btn_crear)
	
	var btn_volver = Button.new()
	btn_volver.text = "< VOLVER"
	btn_volver.position = Vector2(225, 410)
	btn_volver.size = Vector2(150, 38)
	menu_view.aplicar_boton_pixel(btn_volver, Color(0.35, 0.1, 0.1), Color(0.8, 0.3, 0.3), 10)
	btn_volver.pressed.connect(func():
		panel_sel.queue_free()
		_mostrar_solo_panel(menu_view.panel_categorias)
	)
	btn_volver.mouse_entered.connect(_on_hover)
	ventana.add_child(btn_volver)

func _mostrar_confirmacion_borrar_categoria(nombre: String, panel_anterior: Control):
	var popup = AcceptDialog.new()
	popup.title = "Eliminar categoria"
	popup.dialog_text = "¿Seguro que deseas eliminar la categoria '" + nombre + "'?"
	popup.ok_button_text = "Eliminar"
	popup.confirmed.connect(func():
		CustomCategoryModel.eliminar_categoria(nombre)
		panel_anterior.queue_free()
		_abrir_selector_personalizada()
		popup.queue_free()
	)
	popup.canceled.connect(func():
		popup.queue_free()
	)
	add_child(popup)
	popup.popup_centered()

func _editar_categoria_custom(nombre: String):
	var preguntas = CustomCategoryModel.cargar_categoria(nombre)
	if preguntas.is_empty():
		return
	
	preguntas_custom = preguntas.duplicate(true)
	nombre_categoria_editando = nombre
	
	custom_cat_view.resetear_editor()
	custom_cat_view.cargar_categoria_en_editor(
		nombre,
		preguntas_custom,
		Callable(self, "_on_editar_pregunta_custom"),
		Callable(self, "_on_eliminar_pregunta_custom"),
		Callable(self, "_on_hover")
	)
	_mostrar_solo_panel(custom_cat_view.panel_editor)

func _on_agregar_pregunta_custom():
	var datos = custom_cat_view.obtener_datos_formulario()
	
	if datos["pregunta"] == "":
		custom_cat_view.mostrar_estado("Escribe la pregunta", Color(1, 0.3, 0.3))
		return
	
	for op in datos["opciones"]:
		if op == "":
			custom_cat_view.mostrar_estado("Completa todas las opciones", Color(1, 0.3, 0.3))
			return
	
	if custom_cat_view.esta_editando_pregunta():
		var indice = custom_cat_view.obtener_indice_editando_pregunta()
		if indice >= 0 and indice < preguntas_custom.size():
			preguntas_custom[indice] = datos
			custom_cat_view.reconstruir_lista(
				preguntas_custom,
				Callable(self, "_on_editar_pregunta_custom"),
				Callable(self, "_on_eliminar_pregunta_custom"),
				Callable(self, "_on_hover")
			)
			custom_cat_view.salir_modo_edicion_pregunta()
			custom_cat_view.actualizar_contador(preguntas_custom.size())
			custom_cat_view.mostrar_estado("Pregunta actualizada", Color(0.3, 1, 0.3))
		return
	
	preguntas_custom.append(datos)
	custom_cat_view.limpiar_formulario()
	custom_cat_view.actualizar_contador(preguntas_custom.size())
	custom_cat_view.agregar_pregunta_a_lista(
		preguntas_custom.size() - 1,
		datos["pregunta"],
		Callable(self, "_on_editar_pregunta_custom"),
		Callable(self, "_on_eliminar_pregunta_custom"),
		Callable(self, "_on_hover")
	)
	custom_cat_view.mostrar_estado("Pregunta agregada!", Color(0.3, 1, 0.3))

func _on_editar_pregunta_custom(indice):
	if indice >= 0 and indice < preguntas_custom.size():
		custom_cat_view.cargar_pregunta_en_formulario(preguntas_custom[indice], indice)

func _on_eliminar_pregunta_custom(indice):
	if indice >= 0 and indice < preguntas_custom.size():
		preguntas_custom.remove_at(indice)
		custom_cat_view.actualizar_contador(preguntas_custom.size())
		custom_cat_view.reconstruir_lista(
			preguntas_custom,
			Callable(self, "_on_editar_pregunta_custom"),
			Callable(self, "_on_eliminar_pregunta_custom"),
			Callable(self, "_on_hover")
		)
		custom_cat_view.salir_modo_edicion_pregunta()
		custom_cat_view.mostrar_estado("Pregunta eliminada", Color(1, 0.5, 0.3))

func _on_guardar_categoria_custom():
	var nombre = custom_cat_view.obtener_nombre_categoria()
	if nombre == "":
		custom_cat_view.mostrar_estado("Escribe un nombre para la categoria", Color(1, 0.3, 0.3))
		return
	
	if not CustomCategoryModel.nombre_valido(nombre):
		custom_cat_view.mostrar_estado("Nombre invalido para la categoria", Color(1, 0.3, 0.3))
		return
	
	if preguntas_custom.size() < 42:
		custom_cat_view.mostrar_estado("Necesitas minimo 42 preguntas", Color(1, 0.3, 0.3))
		return
	
	# Manejo correcto de renombrado
	if nombre_categoria_editando != "" and nombre != nombre_categoria_editando:
		if CustomCategoryModel.existe_categoria(nombre):
			custom_cat_view.mostrar_estado("Ya existe una categoria con ese nombre", Color(1, 0.3, 0.3))
			return
		CustomCategoryModel.eliminar_categoria(nombre_categoria_editando) # Eliminamos el viejo porque guardaremos uno nuevo
	elif nombre_categoria_editando == "" and CustomCategoryModel.existe_categoria(nombre):
		custom_cat_view.mostrar_estado("Ya existe una categoria con ese nombre", Color(1, 0.3, 0.3))
		return
	
	# Guardar (sobrescribe o crea el nuevo archivo renombrado)
	var resultado = CustomCategoryModel.guardar_categoria(nombre, preguntas_custom, true)
	if resultado["ok"]:
		nombre_categoria_editando = nombre
		custom_cat_view.establecer_modo_edicion(nombre)
		custom_cat_view.mostrar_estado("Categoria '" + nombre + "' guardada!", Color(0.3, 1, 0.3))
		await get_tree().create_timer(1.2).timeout
		custom_cat_view.panel_editor.hide()
		_abrir_selector_personalizada()
	else:
		custom_cat_view.mostrar_estado(resultado["motivo"], Color(1, 0.3, 0.3))

func _on_importar_categoria():
	var fd = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.filters = PackedStringArray(["*.json ; Archivos JSON"])
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.title = "Importar preguntas (JSON)"
	fd.size = Vector2(700, 500)
	add_child(fd)
	fd.popup_centered()
	
	fd.file_selected.connect(func(ruta):
		var resultado = CustomCategoryModel.importar_desde_archivo(ruta)
		if resultado["ok"]:
			preguntas_importadas_pendientes = resultado["preguntas"].duplicate(true)
			_mostrar_opciones_importacion()
		else:
			custom_cat_view.mostrar_estado(resultado["motivo"], Color(1, 0.3, 0.3))
		fd.queue_free()
	)
	fd.canceled.connect(func(): fd.queue_free())

func _mostrar_opciones_importacion():
	var panel = Control.new()
	panel.name = "PanelImportOptions"
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.z_index = 400
	add_child(panel)
	
	var fondo = ColorRect.new()
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.color = Color(0, 0, 0, 0.9)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(fondo)
	
	var ventana = Panel.new()
	ventana.position = Vector2(326, 180)
	ventana.size = Vector2(500, 270)
	ventana.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.05, 0.05, 0.16, 0.98), Color(0.7, 0.5, 0.15)
	))
	panel.add_child(ventana)
	
	var titulo = Label.new()
	titulo.text = "IMPORTAR PREGUNTAS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(0, 20)
	titulo.size = Vector2(500, 30)
	TemaPixel.aplicar_fuente_label(titulo, 16)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ventana.add_child(titulo)
	
	var info = Label.new()
	info.text = "Se encontraron " + str(preguntas_importadas_pendientes.size()) + " preguntas.\n¿Que deseas hacer?"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.position = Vector2(40, 65)
	info.size = Vector2(420, 50)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD
	TemaPixel.aplicar_fuente_label(info, 10)
	info.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	ventana.add_child(info)
	
	var btn_reemplazar = Button.new()
	btn_reemplazar.text = "REEMPLAZAR ACTUALES"
	btn_reemplazar.position = Vector2(110, 130)
	btn_reemplazar.size = Vector2(280, 40)
	menu_view.aplicar_boton_pixel(btn_reemplazar, Color(0.1, 0.3, 0.5), Color(0.3, 0.7, 1), 10)
	btn_reemplazar.pressed.connect(func():
		preguntas_custom = preguntas_importadas_pendientes.duplicate(true)
		custom_cat_view.actualizar_contador(preguntas_custom.size())
		custom_cat_view.reconstruir_lista(
			preguntas_custom,
			Callable(self, "_on_editar_pregunta_custom"),
			Callable(self, "_on_eliminar_pregunta_custom"),
			Callable(self, "_on_hover")
		)
		custom_cat_view.mostrar_estado("Preguntas reemplazadas: " + str(preguntas_custom.size()), Color(0.3, 1, 0.3))
		preguntas_importadas_pendientes.clear()
		panel.queue_free()
	)
	btn_reemplazar.mouse_entered.connect(_on_hover)
	ventana.add_child(btn_reemplazar)
	
	var btn_agregar = Button.new()
	btn_agregar.text = "AGREGAR AL FINAL"
	btn_agregar.position = Vector2(110, 180)
	btn_agregar.size = Vector2(280, 40)
	menu_view.aplicar_boton_pixel(btn_agregar, Color(0.06, 0.35, 0.12), Color(0.15, 0.8, 0.3), 10)
	btn_agregar.pressed.connect(func():
		preguntas_custom.append_array(preguntas_importadas_pendientes.duplicate(true))
		custom_cat_view.actualizar_contador(preguntas_custom.size())
		custom_cat_view.reconstruir_lista(
			preguntas_custom,
			Callable(self, "_on_editar_pregunta_custom"),
			Callable(self, "_on_eliminar_pregunta_custom"),
			Callable(self, "_on_hover")
		)
		custom_cat_view.mostrar_estado("Preguntas agregadas. Total: " + str(preguntas_custom.size()), Color(0.3, 1, 0.3))
		preguntas_importadas_pendientes.clear()
		panel.queue_free()
	)
	btn_agregar.mouse_entered.connect(_on_hover)
	ventana.add_child(btn_agregar)
	
	var btn_cancelar = Button.new()
	btn_cancelar.text = "CANCELAR"
	btn_cancelar.position = Vector2(175, 228)
	btn_cancelar.size = Vector2(150, 30)
	menu_view.aplicar_boton_pixel(btn_cancelar, Color(0.35, 0.1, 0.1), Color(0.8, 0.3, 0.3), 9)
	btn_cancelar.pressed.connect(func():
		preguntas_importadas_pendientes.clear()
		panel.queue_free()
	)
	btn_cancelar.mouse_entered.connect(_on_hover)
	ventana.add_child(btn_cancelar)

func _on_exportar_plantilla_categoria():
	var fd = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.filters = PackedStringArray(["*.json ; Archivo JSON"])
	fd.title = "Guardar plantilla JSON"
	fd.current_file = "plantilla_categoria.json"
	fd.size = Vector2(700, 500)
	add_child(fd)
	fd.popup_centered()
	
	fd.file_selected.connect(func(ruta):
		var resultado = CustomCategoryModel.exportar_plantilla(ruta)
		if resultado["ok"]:
			custom_cat_view.mostrar_estado("Plantilla exportada correctamente", Color(0.3, 1, 0.3))
		else:
			custom_cat_view.mostrar_estado(resultado["motivo"], Color(1, 0.3, 0.3))
		fd.queue_free()
	)
	fd.canceled.connect(func(): fd.queue_free())

func _on_volver_editor_custom():
	custom_cat_view.panel_editor.hide()
	_abrir_selector_personalizada()

func _on_confirmar_categoria():
	# Al seleccionar la categoría custom, la variable ya viene como "custom_Nombre"
	if Global.es_multijugador:
		rpc("rpc_iniciar_juego", categoria_seleccionada)
	else:
		Global.categoria = categoria_seleccionada
		get_tree().change_scene_to_file("res://juego_principal.tscn")

func _texto_corto(texto: String, max_chars: int = 24) -> String:
	var limpio = texto.strip_edges()
	if limpio.length() <= max_chars:
		return limpio
	return limpio.substr(0, max_chars).strip_edges() + " ..."

func _on_volver_menu():
	if menu_view.panel_categorias and menu_view.panel_categorias.visible:
		if Global.es_multijugador:
			rpc("rpc_rival_abandono")
			await get_tree().create_timer(0.1).timeout 
			NetworkHelper.desconectar()
			get_tree().change_scene_to_file("res://menu_principal.tscn")
			return
		
		# En local, simplemente recargamos para evitar bugs visuales
		get_tree().change_scene_to_file("res://menu_principal.tscn")
		return
	
	if menu_view.panel_online and menu_view.panel_online.visible:
		_mostrar_solo_panel(menu_view.panel_modo)
		return
	
	_mostrar_solo_panel(null)

func _actualizar_textos_volver(nuevo_texto: String):
	var nodos_a_revisar = [self, menu_view.panel_categorias, menu_view.panel_modo, menu_view.panel_online]
	for nodo in nodos_a_revisar:
		if nodo:
			for child in nodo.get_children():
				if child is Button and ("VOLVER" in child.text or "MENU" in child.text) and child.text.begins_with("<"):
					child.text = nuevo_texto

# ====== MODO DE JUEGO ======
func _on_modo_local():
	Global.es_multijugador = false
	menu_view.colocar_boton_volver_superior(menu_view.panel_categorias)
	_mostrar_solo_panel(menu_view.panel_categorias)

func _on_modo_online():
	menu_view.actualizar_estado_red("Esperando accion...", Color(0.7, 0.7, 0.7))
	_mostrar_solo_panel(menu_view.panel_online)

func _on_volver_online():
	if Global.es_multijugador and Red.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		rpc("rpc_rival_abandono")
		await get_tree().create_timer(0.1).timeout
		
	NetworkHelper.desconectar()
	get_tree().change_scene_to_file("res://menu_principal.tscn")

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
		menu_view.colocar_boton_volver_superior(menu_view.panel_categorias)
		_mostrar_solo_panel(menu_view.panel_categorias)
	else:
		menu_view.actualizar_estado_red("¡Conectado! Esperando a que el Host inicie...", Color(0.2, 1.0, 0.2))

func _on_red_conexion_fallida():
	menu_view.actualizar_estado_red("Error al conectar. Verifica la IP.", Color(1.0, 0.2, 0.2))

func _mostrar_solo_panel(panel_objetivo):
	var btn_jugar = get_node_or_null("BotonJugar")
	var btn_instr = get_node_or_null("BotonInstrucciones")
	var btn_salir = get_node_or_null("BotonSalir")
	var titulo = get_node_or_null("Titulo")
	var subtitulo = get_node_or_null("Subtitulo")
	var btn_info = get_node_or_null("BtnInfo")
	var btn_musica = get_node_or_null("BotonMusica")
	var btn_fs = get_node_or_null("BotonFullscreen")
	
	if btn_jugar: btn_jugar.hide()
	if btn_instr: btn_instr.hide()
	if btn_salir: btn_salir.hide()
	if titulo: titulo.hide()
	if subtitulo: subtitulo.hide()
	if btn_info: btn_info.hide()
	if btn_musica: btn_musica.hide()
	if btn_fs: btn_fs.hide()
	
	if menu_view.panel_modo: menu_view.panel_modo.hide()
	if menu_view.panel_online: menu_view.panel_online.hide()
	if menu_view.panel_instrucciones: menu_view.panel_instrucciones.hide()
	if menu_view.panel_categorias: menu_view.panel_categorias.hide()
	if menu_view.panel_creditos: menu_view.panel_creditos.hide()
	if custom_cat_view.panel_editor: custom_cat_view.panel_editor.hide()
	
	# ELIMINAR nodos dinámicos, no solo ocultarlos (Evita bugs de UI sobrepuesta)
	var panel_sel = get_node_or_null("PanelSelCustom")
	if panel_sel: panel_sel.queue_free()
	
	var panel_import = get_node_or_null("PanelImportOptions")
	if panel_import: panel_import.queue_free()
	
	if panel_objetivo == null:
		if btn_jugar: btn_jugar.show()
		if btn_instr: btn_instr.show()
		if btn_salir: btn_salir.show()
		if titulo: titulo.show()
		if subtitulo: subtitulo.show()
		if btn_info: btn_info.show()
		if btn_musica: btn_musica.show()
		if btn_fs: btn_fs.show()
	else:
		panel_objetivo.show()

func _ocultar_elementos_fondo():
	var nombres = [
		"BotonJugar",
		"BotonInstrucciones",
		"BotonSalir",
		"Titulo",
		"Subtitulo",
		"BtnInfo"
	]
	
	for nombre in nombres:
		var nodo = get_node_or_null(nombre)
		if nodo:
			nodo.hide()
	
	if menu_view.panel_modo:
		menu_view.panel_modo.hide()
	if menu_view.panel_online:
		menu_view.panel_online.hide()
	if menu_view.panel_instrucciones:
		menu_view.panel_instrucciones.hide()
	if menu_view.panel_categorias:
		menu_view.panel_categorias.hide()
	if menu_view.panel_creditos:
		menu_view.panel_creditos.hide()
	if custom_cat_view.panel_editor:
		custom_cat_view.panel_editor.hide()

func _mostrar_menu_principal():
	var nombres = [
		"BotonJugar",
		"BotonInstrucciones",
		"BotonSalir",
		"Titulo",
		"Subtitulo",
		"BtnInfo"
	]
	
	for nombre in nombres:
		var nodo = get_node_or_null(nombre)
		if nodo:
			nodo.show()
	
	var btn_musica = get_node_or_null("BotonMusica")
	var btn_fs = get_node_or_null("BotonFullscreen")
	if btn_musica:
		btn_musica.show()
	if btn_fs:
		btn_fs.show()

# ====== RPC ======
@rpc("any_peer", "call_local", "reliable")
func rpc_iniciar_juego(categoria_elegida):
	Global.categoria = categoria_elegida
	get_tree().change_scene_to_file("res://juego_principal.tscn")

@rpc("any_peer", "call_remote", "reliable")
func rpc_rival_abandono():
	NetworkHelper.desconectar()
	# Lo llevamos forzosamente al panel online y le mostramos el mensaje rojo
	_mostrar_solo_panel(menu_view.panel_online)
	if menu_view:
		menu_view.actualizar_estado_red("El rival ha abandonado la sala.", Color(1.0, 0.2, 0.2))
