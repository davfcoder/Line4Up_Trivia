extends Control

# ====== CLASE PARA ICONO FULLSCREEN DINÁMICO ======
class IconoFullscreen extends Control:
	var is_fullscreen = false
	
	func actualizar_estado(estado):
		is_fullscreen = estado
		queue_redraw()

	func _draw():
		var c = Color(1, 1, 1, 0.9)
		if not is_fullscreen:
			# Expandir (Esquinas apuntando hacia AFUERA ⌜ ⌝ ⌞ ⌟)
			draw_rect(Rect2(12, 12, 9, 3), c)
			draw_rect(Rect2(12, 12, 3, 9), c)
			draw_rect(Rect2(24, 12, 9, 3), c)
			draw_rect(Rect2(30, 12, 3, 9), c)
			draw_rect(Rect2(12, 30, 9, 3), c)
			draw_rect(Rect2(12, 24, 3, 9), c)
			draw_rect(Rect2(24, 30, 9, 3), c)
			draw_rect(Rect2(30, 24, 3, 9), c)
		else:
			# Contraer (Esquinas apuntando hacia ADENTRO ⌟ ⌞ ⌝ ⌜)
			draw_rect(Rect2(13, 19, 9, 3), c)
			draw_rect(Rect2(19, 13, 3, 9), c)
			draw_rect(Rect2(23, 19, 9, 3), c)
			draw_rect(Rect2(23, 13, 3, 9), c)
			draw_rect(Rect2(13, 23, 9, 3), c)
			draw_rect(Rect2(19, 23, 3, 9), c)
			draw_rect(Rect2(23, 23, 9, 3), c)
			draw_rect(Rect2(23, 23, 3, 9), c)

var panel_instrucciones = null
var panel_categorias = null
var panel_creditos = null
var categoria_seleccionada = "ingles"

const TemaPixel = preload("res://efectos/tema_pixel.gd")
const IconoPixel = preload("res://efectos/icono_pixel.gd")
const FondoEspacial = preload("res://efectos/fondo_espacial.gd")

var categorias_disponibles = {
	"ingles": "INGLES",
	"cultura_general": "CULTURA GENERAL",
	"programacion": "PROGRAMACION",
	"ciencias": "CIENCIAS",
	"historia": "HISTORIA"
}

var categorias_icono_tipo = {
	"ingles": "cat_ingles",
	"cultura_general": "cat_cultura",
	"programacion": "cat_programacion",
	"ciencias": "cat_ciencias",
	"historia": "cat_historia"
}

func _ready():
	var fondo = $FondoMenu
	fondo.color = Color(0.03, 0.03, 0.1)
	fondo.position = Vector2(0, 0)
	fondo.size = Vector2(1152, 648)
	fondo.z_index = -20
	
	# Fondo espacial animado
	var espacio = Node2D.new()
	espacio.set_script(FondoEspacial)
	add_child(espacio)
	
	# Línea decorativa superior
	var linea_top = ColorRect.new()
	linea_top.position = Vector2(0, 0)
	linea_top.size = Vector2(1152, 3)
	linea_top.color = Color(0.2, 0.4, 0.8, 0.5)
	add_child(linea_top)
	
	var titulo = $Titulo
	titulo.text = "LINE 4 UP"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(176, 40)
	titulo.size = Vector2(800, 70)
	TemaPixel.aplicar_fuente_label(titulo, 44)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	
	var subtitulo = $Subtitulo
	subtitulo.text = "~ TRIVIA EDITION ~"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.position = Vector2(276, 105)
	subtitulo.size = Vector2(600, 35)
	TemaPixel.aplicar_fuente_label(subtitulo, 14)
	subtitulo.add_theme_color_override("font_color", Color(0.5, 0.7, 1))
	
	var linea_deco = Label.new()
	linea_deco.text = "================================"
	linea_deco.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	linea_deco.position = Vector2(226, 135)
	linea_deco.size = Vector2(700, 20)
	TemaPixel.aplicar_fuente_label(linea_deco, 8)
	linea_deco.add_theme_color_override("font_color", Color(0.2, 0.35, 0.6, 0.6))
	add_child(linea_deco)
	
	# Fichas decorativas a los lados del título
	var ficha_deco_izq = IconoPixel.crear("ficha_roja", 36)
	ficha_deco_izq.position = Vector2(230, 42)
	add_child(ficha_deco_izq)
	var ficha_deco_der = IconoPixel.crear("ficha_amarilla", 36)
	ficha_deco_der.position = Vector2(886, 42)
	add_child(ficha_deco_der)
	
	# Botones
	var btn_jugar = $BotonJugar
	btn_jugar.text = "> JUGAR <"
	btn_jugar.position = Vector2(376, 195)
	btn_jugar.size = Vector2(400, 75)
	aplicar_boton_pixel(btn_jugar, Color(0.06, 0.38, 0.12), Color(0.15, 0.85, 0.25), 20)
	btn_jugar.pressed.connect(_on_jugar)
	agregar_hover_sonido(btn_jugar)
	
	var btn_instrucciones = Button.new()
	btn_instrucciones.text = "INSTRUCCIONES"
	btn_instrucciones.position = Vector2(401, 295)
	btn_instrucciones.size = Vector2(350, 58)
	aplicar_boton_pixel(btn_instrucciones, Color(0.1, 0.12, 0.35), Color(0.25, 0.4, 0.85), 14)
	btn_instrucciones.pressed.connect(_on_instrucciones)
	agregar_hover_sonido(btn_instrucciones)
	add_child(btn_instrucciones)
	
	var btn_salir = $BotonSalir
	btn_salir.text = "SALIR"
	btn_salir.position = Vector2(451, 430)
	btn_salir.size = Vector2(250, 50)
	aplicar_boton_pixel(btn_salir, Color(0.35, 0.06, 0.06), Color(0.85, 0.2, 0.2), 14)
	btn_salir.pressed.connect(_on_salir)
	agregar_hover_sonido(btn_salir)
	
	# Botón INFO
	var btn_info = Button.new()
	btn_info.name = "BtnInfo"
	btn_info.text = ""
	btn_info.position = Vector2(1080, 585)
	btn_info.size = Vector2(35, 35)
	btn_info.z_index = 10
	var estilos_info = TemaPixel.crear_boton_pixel(Color(0.1, 0.1, 0.25, 0.7), Color(0.3, 0.4, 0.7))
	btn_info.add_theme_stylebox_override("normal", estilos_info["normal"])
	btn_info.add_theme_stylebox_override("hover", estilos_info["hover"])
	btn_info.pressed.connect(_on_info)
	agregar_hover_sonido(btn_info)
	add_child(btn_info)
	var icono_info = IconoPixel.crear("info", 22, Color(0.5, 0.7, 1))
	icono_info.position = Vector2(6, 6)
	btn_info.add_child(icono_info)
	
	var label_version = Label.new()
	label_version.text = "v1.0"
	label_version.position = Vector2(1080, 622)
	label_version.size = Vector2(60, 20)
	TemaPixel.aplicar_fuente_label(label_version, 7)
	label_version.add_theme_color_override("font_color", Color(0.25, 0.25, 0.35))
	add_child(label_version)
	
	# Texto decorativo inferior
	var deco_bottom = Label.new()
	deco_bottom.text = "~ Conecta 4 fichas para ganar ~"
	deco_bottom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	deco_bottom.position = Vector2(326, 520)
	deco_bottom.size = Vector2(500, 20)
	TemaPixel.aplicar_fuente_label(deco_bottom, 8)
	deco_bottom.add_theme_color_override("font_color", Color(0.3, 0.4, 0.55, 0.5))
	add_child(deco_bottom)
	
	crear_panel_instrucciones()
	crear_panel_categorias()
	crear_panel_creditos()
	
	$MusicaMenu.stream = preload("res://musica/menu_theme.wav")
	$MusicaMenu.volume_db = -13
	if Global.musica_activa:
		$MusicaMenu.play()
	$MusicaMenu.finished.connect(_on_musica_menu_terminada)
	
	Global.crear_boton_musica(self, _on_toggle_musica)
	
		# --- BOTÓN PANTALLA COMPLETA ---
	var btn_fs = Button.new()
	btn_fs.name = "BotonFullscreen"
	btn_fs.position = Vector2(60, 10) # Al lado del botón de música
	btn_fs.size = Vector2(45, 45)
	btn_fs.z_index = 50
	
	# Le aplicamos el mismo estilo pixel retro oscuro
	var estilos_fs = TemaPixel.crear_boton_pixel(Color(0.12, 0.12, 0.25, 0.85), Color(0.35, 0.4, 0.7))
	btn_fs.add_theme_stylebox_override("normal", estilos_fs["normal"])
	btn_fs.add_theme_stylebox_override("hover", estilos_fs["hover"])
	btn_fs.add_theme_stylebox_override("pressed", estilos_fs["pressed"])
	
	btn_fs.pressed.connect(_on_toggle_fullscreen)
	agregar_hover_sonido(btn_fs)
	
	# Agregamos el icono dibujado
	var icono_fs = IconoFullscreen.new()
	icono_fs.name = "IconoFS"
	icono_fs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_fs.add_child(icono_fs)
	add_child(btn_fs)
	
	# Sincronizar el dibujo del icono con el estado actual de la ventana al abrir el juego
	var modo_actual = DisplayServer.window_get_mode()
	icono_fs.actualizar_estado(modo_actual == DisplayServer.WINDOW_MODE_FULLSCREEN or modo_actual == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	# Auto-abrir categorías si viene de "jugar de nuevo"
	if Global.abrir_categorias:
		Global.abrir_categorias = false
		panel_categorias.show()

func aplicar_boton_pixel(boton, color_fondo, color_borde, tam_fuente: int = 13):
	var estilos = TemaPixel.crear_boton_pixel(color_fondo, color_borde)
	boton.add_theme_stylebox_override("normal", estilos["normal"])
	boton.add_theme_stylebox_override("hover", estilos["hover"])
	boton.add_theme_stylebox_override("pressed", estilos["pressed"])
	boton.add_theme_color_override("font_color", Color(1, 1, 1))
	boton.add_theme_color_override("font_hover_color", Color(1, 1, 0.7))
	TemaPixel.aplicar_fuente_boton(boton, tam_fuente)

func _on_toggle_musica():
	Global.musica_activa = !Global.musica_activa
	var btn = get_node_or_null("BotonMusica")
	Global.actualizar_boton_musica(btn)
	if Global.musica_activa:
		if not $MusicaMenu.playing:
			$MusicaMenu.play()
	else:
		$MusicaMenu.stop()

func _on_musica_menu_terminada():
	$MusicaMenu.play()

# ====== PANEL DE CATEGORÍAS ======
func crear_panel_categorias():
	panel_categorias = Control.new()
	panel_categorias.name = "PanelCategorias"
	panel_categorias.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_categorias.hide()
	add_child(panel_categorias)
	
	var fondo_oscuro = ColorRect.new()
	fondo_oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo_oscuro.color = Color(0, 0, 0, 0.8)
	panel_categorias.add_child(fondo_oscuro)
	
	var btn_volver = Button.new()
	btn_volver.name = "BtnVolver"
	btn_volver.text = "< VOLVER"
	btn_volver.position = Vector2(10, 62)
	btn_volver.size = Vector2(140, 38)
	btn_volver.z_index = 60
	aplicar_boton_pixel(btn_volver, Color(0.35, 0.1, 0.1), Color(0.8, 0.3, 0.3), 10)
	btn_volver.pressed.connect(_on_volver_menu)
	agregar_hover_sonido(btn_volver)
	panel_categorias.add_child(btn_volver)
	
	var ventana = Panel.new()
	ventana.name = "VentanaCategorias"
	ventana.position = Vector2(276, 30)
	ventana.size = Vector2(600, 560)
	ventana.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.05, 0.05, 0.16, 0.97), Color(0.2, 0.4, 0.85)
	))
	panel_categorias.add_child(ventana)
	
	var titulo_cat = Label.new()
	titulo_cat.text = "ELIGE CATEGORIA"
	titulo_cat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo_cat.position = Vector2(0, 16)
	titulo_cat.size = Vector2(600, 40)
	TemaPixel.aplicar_fuente_label(titulo_cat, 18)
	titulo_cat.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ventana.add_child(titulo_cat)
	
	var y_offset = 65
	var btn_height = 58
	var btn_spacing = 10
	var btn_width = 480
	var btn_x = 60
	
	var indice = 0
	for clave in categorias_disponibles.keys():
		# Contenedor para botón + ícono
		var btn_cat = Button.new()
		btn_cat.name = "BtnCat_" + clave
		btn_cat.text = "     " + categorias_disponibles[clave]
		btn_cat.position = Vector2(btn_x, y_offset + indice * (btn_height + btn_spacing))
		btn_cat.size = Vector2(btn_width, btn_height)
		aplicar_boton_pixel(btn_cat, Color(0.08, 0.08, 0.2), Color(0.2, 0.3, 0.6), 13)
		btn_cat.pressed.connect(_on_categoria_seleccionada.bind(clave))
		agregar_hover_sonido(btn_cat)
		ventana.add_child(btn_cat)
		
		# Ícono pixel art dentro del botón
		var icono_cat = IconoPixel.crear(categorias_icono_tipo[clave], 34)
		icono_cat.position = Vector2(15, 12)
		btn_cat.add_child(icono_cat)
		
		indice += 1
	
	var label_sel = Label.new()
	label_sel.name = "LabelCategoriaSel"
	label_sel.text = "> INGLES"
	label_sel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_sel.position = Vector2(0, y_offset + indice * (btn_height + btn_spacing) + 5)
	label_sel.size = Vector2(600, 28)
	TemaPixel.aplicar_fuente_label(label_sel, 12)
	label_sel.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
	ventana.add_child(label_sel)
	
	var btn_confirmar = Button.new()
	btn_confirmar.name = "BtnConfirmar"
	btn_confirmar.text = ">> COMENZAR <<"
	btn_confirmar.position = Vector2(140, y_offset + indice * (btn_height + btn_spacing) + 42)
	btn_confirmar.size = Vector2(320, 58)
	aplicar_boton_pixel(btn_confirmar, Color(0.06, 0.4, 0.12), Color(0.15, 0.9, 0.3), 16)
	btn_confirmar.pressed.connect(_on_confirmar_categoria)
	agregar_hover_sonido(btn_confirmar)
	ventana.add_child(btn_confirmar)
	
	_resaltar_categoria("ingles")

func _on_categoria_seleccionada(clave):
	categoria_seleccionada = clave
	_resaltar_categoria(clave)
	var ventana = panel_categorias.get_node("VentanaCategorias")
	var label = ventana.get_node("LabelCategoriaSel")
	label.text = "> " + categorias_disponibles[clave]

func _resaltar_categoria(clave_seleccionada):
	var ventana = panel_categorias.get_node("VentanaCategorias")
	for clave in categorias_disponibles.keys():
		var btn = ventana.get_node_or_null("BtnCat_" + clave)
		if btn:
			if clave == clave_seleccionada:
				aplicar_boton_pixel(btn, Color(0.1, 0.28, 0.5), Color(0.25, 0.65, 1), 13)
			else:
				aplicar_boton_pixel(btn, Color(0.08, 0.08, 0.2), Color(0.2, 0.3, 0.6), 13)

func _on_confirmar_categoria():
	Global.categoria = categoria_seleccionada
	get_tree().change_scene_to_file("res://juego_principal.tscn")

func _on_volver_menu():
	panel_categorias.hide()

# ====== CRÉDITOS ======
func crear_panel_creditos():
	panel_creditos = Control.new()
	panel_creditos.name = "PanelCreditos"
	panel_creditos.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_creditos.hide()
	add_child(panel_creditos)
	
	var fondo_oscuro = ColorRect.new()
	fondo_oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo_oscuro.color = Color(0, 0, 0, 0.85)
	panel_creditos.add_child(fondo_oscuro)
	
	var ventana = Panel.new()
	ventana.position = Vector2(276, 80)
	ventana.size = Vector2(600, 488)
	ventana.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.05, 0.05, 0.16, 0.98), Color(0.25, 0.4, 0.8)
	))
	panel_creditos.add_child(ventana)
	
	var titulo_c = Label.new()
	titulo_c.text = "INFORMACION"
	titulo_c.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo_c.position = Vector2(0, 18)
	titulo_c.size = Vector2(600, 35)
	TemaPixel.aplicar_fuente_label(titulo_c, 20)
	titulo_c.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ventana.add_child(titulo_c)
	
	var info_lines = [
		"", "LINE 4 UP: TRIVIA EDITION", "",
		"Version: 1.0", "",
		"Desarrollado con:", "  Godot Engine 4.6.1", "",
		"Desarrollado por:", "  davfcoder", "",
		"Genero: Trivia / Estrategia", "Modo: 1 vs 1 Local", "",
		"Un juego de conecta cuatro", "combinado con trivia educativa",
		"para estudiantes universitarios.", "",
		"Repositorio","https://github.com/davfcoder/LineUp4_Trivia.git", "",
		"2026"
	]
	
	var y_pos = 60
	for linea in info_lines:
		var lbl = Label.new()
		lbl.text = linea
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.position = Vector2(0, y_pos)
		lbl.size = Vector2(600, 18)
		TemaPixel.aplicar_fuente_label(lbl, 9)
		if linea == "LINE 4 UP: TRIVIA EDITION":
			lbl.add_theme_color_override("font_color", Color(0.4, 0.8, 1))
			TemaPixel.aplicar_fuente_label(lbl, 12)
		elif linea.begins_with("  "):
			lbl.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
		else:
			lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
		ventana.add_child(lbl)
		y_pos += 18
	
	var btn_cerrar_c = Button.new()
	btn_cerrar_c.text = "CERRAR"
	btn_cerrar_c.position = Vector2(225, 435)
	btn_cerrar_c.size = Vector2(150, 40)
	aplicar_boton_pixel(btn_cerrar_c, Color(0.35, 0.06, 0.06), Color(0.8, 0.2, 0.2), 11)
	btn_cerrar_c.pressed.connect(func(): panel_creditos.hide())
	agregar_hover_sonido(btn_cerrar_c)
	ventana.add_child(btn_cerrar_c)

func _on_info():
	panel_creditos.show()

# ====== INSTRUCCIONES ======
func crear_panel_instrucciones():
	panel_instrucciones = Control.new()
	panel_instrucciones.name = "PanelInstrucciones"
	panel_instrucciones.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_instrucciones.hide()
	add_child(panel_instrucciones)
	
	var fondo_oscuro = ColorRect.new()
	fondo_oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo_oscuro.color = Color(0, 0, 0, 0.85)
	panel_instrucciones.add_child(fondo_oscuro)
	
	var ventana = Panel.new()
	ventana.position = Vector2(76, 24)
	ventana.size = Vector2(1000, 600)
	ventana.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.05, 0.05, 0.16, 0.98), Color(0.2, 0.4, 0.85)
	))
	panel_instrucciones.add_child(ventana)
	
	var titulo_inst = Label.new()
	titulo_inst.text = "INSTRUCCIONES"
	titulo_inst.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo_inst.position = Vector2(250, 15)
	titulo_inst.size = Vector2(500, 40)
	TemaPixel.aplicar_fuente_label(titulo_inst, 22)
	titulo_inst.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ventana.add_child(titulo_inst)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(25, 60)
	scroll.size = Vector2(950, 470)
	ventana.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	
	agregar_seccion(vbox, ":: OBJETIVO ::", ["Conecta 4 fichas en linea para ganar."])
	agregar_seccion(vbox, ":: COMO EMPEZAR ::", [
		"1. Presiona JUGAR.", "2. Elige una categoria.", "3. Presiona COMENZAR."
	])
	agregar_seccion(vbox, ":: MECANICA ::", [
		"Responde preguntas cada turno.", "Acierto = lanza ficha.", "Fallo = pierdes turno.", "20 segundos por pregunta."
	])
	agregar_seccion(vbox, ":: PODERES (racha de 2) ::", [
		"[BOMBA] Destruye ficha enemiga.", "[HIELO] Congela una columna."
	])
	agregar_seccion(vbox, ":: CONTROLES ::", [
		"[1] Normal  [2] Bomba  [3] Hielo", "[ESC] Cancelar  [P] Pausar"
	])
	agregar_seccion(vbox, ":: MUSICA ::", ["Boton en esquina superior izquierda."])
	
	var btn_cerrar = Button.new()
	btn_cerrar.text = "CERRAR [X]"
	btn_cerrar.position = Vector2(400, 542)
	btn_cerrar.size = Vector2(200, 45)
	aplicar_boton_pixel(btn_cerrar, Color(0.35, 0.06, 0.06), Color(0.8, 0.2, 0.2), 12)
	btn_cerrar.pressed.connect(_on_cerrar_instrucciones)
	agregar_hover_sonido(btn_cerrar)
	ventana.add_child(btn_cerrar)

func agregar_seccion(contenedor, titulo, lineas):
	var sep = Control.new()
	sep.custom_minimum_size = Vector2(0, 10)
	contenedor.add_child(sep)
	var lt = Label.new()
	lt.text = titulo
	TemaPixel.aplicar_fuente_label(lt, 12)
	lt.add_theme_color_override("font_color", Color(0.4, 0.75, 1))
	contenedor.add_child(lt)
	for linea in lineas:
		var ll = Label.new()
		ll.text = linea
		TemaPixel.aplicar_fuente_label(ll, 12)
		ll.add_theme_color_override("font_color", Color(0.78, 0.78, 0.9))
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD
		contenedor.add_child(ll)

func _on_jugar():
	panel_categorias.show()

func _on_instrucciones():
	panel_instrucciones.show()

func _on_cerrar_instrucciones():
	panel_instrucciones.hide()

func _on_salir():
	get_tree().quit()

func agregar_hover_sonido(boton):
	boton.mouse_entered.connect(_on_hover_boton)

func _on_hover_boton():
	$SonidoHover.stream = preload("res://sonidos/hover1.wav")
	$SonidoHover.play()

func _on_toggle_fullscreen():
	var modo_actual = DisplayServer.window_get_mode()
	var es_full = (modo_actual == DisplayServer.WINDOW_MODE_FULLSCREEN or modo_actual == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	if es_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Actualizar el dibujo del icono (invertimos 'es_full' porque acabamos de cambiar el estado)
	var icono = get_node_or_null("BotonFullscreen/IconoFS")
	if icono:
		icono.actualizar_estado(!es_full)

func _input(event):
	# Si presionan F11, se activa la misma función del botón
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		_on_toggle_fullscreen()
