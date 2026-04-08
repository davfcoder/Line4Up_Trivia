class_name MenuView
extends RefCounted

const TemaPixel = preload("res://efectos/tema_pixel.gd")
const IconoPixel = preload("res://efectos/icono_pixel.gd")
const FondoEspacial = preload("res://efectos/fondo_espacial.gd")

var root: Control
var panel_modo = null
var panel_online = null
var panel_instrucciones = null
var panel_categorias = null
var panel_creditos = null
var input_ip = null
var label_estado_red = null

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

func configurar(_root: Control):
	root = _root

func aplicar_boton_pixel(boton, color_fondo, color_borde, tam_fuente: int = 13):
	var estilos = TemaPixel.crear_boton_pixel(color_fondo, color_borde)
	boton.add_theme_stylebox_override("normal", estilos["normal"])
	boton.add_theme_stylebox_override("hover", estilos["hover"])
	boton.add_theme_stylebox_override("pressed", estilos["pressed"])
	boton.add_theme_color_override("font_color", Color(1, 1, 1))
	boton.add_theme_color_override("font_hover_color", Color(1, 1, 0.7))
	TemaPixel.aplicar_fuente_boton(boton, tam_fuente)

func configurar_fondo(fondo_menu):
	fondo_menu.color = Color(0.03, 0.03, 0.1)
	fondo_menu.position = Vector2(0, 0)
	fondo_menu.size = Vector2(1152, 648)
	fondo_menu.z_index = -20

func crear_fondo_espacial():
	var espacio = Node2D.new()
	espacio.set_script(FondoEspacial)
	root.add_child(espacio)

func configurar_titulo(titulo, subtitulo):
	titulo.text = "LINE 4 UP"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(176, 40)
	titulo.size = Vector2(800, 70)
	TemaPixel.aplicar_fuente_label(titulo, 44)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	
	subtitulo.text = "~ TRIVIA EDITION ~"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.position = Vector2(276, 105)
	subtitulo.size = Vector2(600, 35)
	TemaPixel.aplicar_fuente_label(subtitulo, 14)
	subtitulo.add_theme_color_override("font_color", Color(0.5, 0.7, 1))

func crear_decoraciones():
	var linea_top = ColorRect.new()
	linea_top.position = Vector2(0, 0)
	linea_top.size = Vector2(1152, 3)
	linea_top.color = Color(0.2, 0.4, 0.8, 0.5)
	root.add_child(linea_top)
	
	var linea_deco = Label.new()
	linea_deco.text = "================================"
	linea_deco.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	linea_deco.position = Vector2(226, 135)
	linea_deco.size = Vector2(700, 20)
	TemaPixel.aplicar_fuente_label(linea_deco, 8)
	linea_deco.add_theme_color_override("font_color", Color(0.2, 0.35, 0.6, 0.6))
	root.add_child(linea_deco)
	
	var ficha_izq = IconoPixel.crear("ficha_roja", 36)
	ficha_izq.position = Vector2(230, 42)
	root.add_child(ficha_izq)
	var ficha_der = IconoPixel.crear("ficha_amarilla", 36)
	ficha_der.position = Vector2(886, 42)
	root.add_child(ficha_der)
	
	var deco_bottom = Label.new()
	deco_bottom.text = "~ Conecta 4 fichas para ganar ~"
	deco_bottom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	deco_bottom.position = Vector2(326, 520)
	deco_bottom.size = Vector2(500, 20)
	TemaPixel.aplicar_fuente_label(deco_bottom, 8)
	deco_bottom.add_theme_color_override("font_color", Color(0.3, 0.4, 0.55, 0.5))
	root.add_child(deco_bottom)
	
	var label_version = Label.new()
	label_version.text = "v1.0"
	label_version.position = Vector2(1080, 622)
	label_version.size = Vector2(60, 20)
	TemaPixel.aplicar_fuente_label(label_version, 7)
	label_version.add_theme_color_override("font_color", Color(0.25, 0.25, 0.35))
	root.add_child(label_version)

func configurar_botones_principales(btn_jugar, btn_salir, cb_jugar, cb_salir, cb_instrucciones, cb_info, cb_hover):
	btn_jugar.text = "> JUGAR <"
	btn_jugar.position = Vector2(376, 195)
	btn_jugar.size = Vector2(400, 75)
	aplicar_boton_pixel(btn_jugar, Color(0.06, 0.38, 0.12), Color(0.15, 0.85, 0.25), 20)
	btn_jugar.pressed.connect(cb_jugar)
	btn_jugar.mouse_entered.connect(cb_hover)
	
	var btn_instrucciones = Button.new()
	btn_instrucciones.text = "INSTRUCCIONES"
	btn_instrucciones.position = Vector2(401, 295)
	btn_instrucciones.size = Vector2(350, 58)
	aplicar_boton_pixel(btn_instrucciones, Color(0.1, 0.12, 0.35), Color(0.25, 0.4, 0.85), 14)
	btn_instrucciones.pressed.connect(cb_instrucciones)
	btn_instrucciones.mouse_entered.connect(cb_hover)
	root.add_child(btn_instrucciones)
	
	btn_salir.text = "SALIR"
	btn_salir.position = Vector2(451, 430)
	btn_salir.size = Vector2(250, 50)
	aplicar_boton_pixel(btn_salir, Color(0.35, 0.06, 0.06), Color(0.85, 0.2, 0.2), 14)
	btn_salir.pressed.connect(cb_salir)
	btn_salir.mouse_entered.connect(cb_hover)
	
	var btn_info = Button.new()
	btn_info.name = "BtnInfo"
	btn_info.text = ""
	btn_info.position = Vector2(1080, 585)
	btn_info.size = Vector2(35, 35)
	btn_info.z_index = 10
	var estilos_info = TemaPixel.crear_boton_pixel(Color(0.1, 0.1, 0.25, 0.7), Color(0.3, 0.4, 0.7))
	btn_info.add_theme_stylebox_override("normal", estilos_info["normal"])
	btn_info.add_theme_stylebox_override("hover", estilos_info["hover"])
	btn_info.pressed.connect(cb_info)
	btn_info.mouse_entered.connect(cb_hover)
	root.add_child(btn_info)
	var icono_info = IconoPixel.crear("info", 22, Color(0.5, 0.7, 1))
	icono_info.position = Vector2(6, 6)
	btn_info.add_child(icono_info)

func crear_boton_fullscreen(cb_toggle, cb_hover):
	var btn_fs = Button.new()
	btn_fs.name = "BotonFullscreen"
	btn_fs.position = Vector2(60, 10)
	btn_fs.size = Vector2(45, 45)
	btn_fs.z_index = 50
	var estilos_fs = TemaPixel.crear_boton_pixel(Color(0.12, 0.12, 0.25, 0.85), Color(0.35, 0.4, 0.7))
	btn_fs.add_theme_stylebox_override("normal", estilos_fs["normal"])
	btn_fs.add_theme_stylebox_override("hover", estilos_fs["hover"])
	btn_fs.add_theme_stylebox_override("pressed", estilos_fs["pressed"])
	btn_fs.pressed.connect(cb_toggle)
	btn_fs.mouse_entered.connect(cb_hover)
	root.add_child(btn_fs)

func actualizar_icono_fullscreen(es_fullscreen: bool):
	var icono = root.get_node_or_null("BotonFullscreen/IconoFS")
	if icono:
		icono.actualizar_estado(es_fullscreen)

func crear_panel_instrucciones(cb_cerrar, cb_hover):
	panel_instrucciones = Control.new()
	panel_instrucciones.name = "PanelInstrucciones"
	panel_instrucciones.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_instrucciones.hide()
	root.add_child(panel_instrucciones)
	
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
	
	_agregar_seccion(vbox, ":: OBJETIVO ::", ["Conecta 4 fichas en linea para ganar."])
	_agregar_seccion(vbox, ":: COMO EMPEZAR ::", ["1. Presiona JUGAR.", "2. Elige una categoria.", "3. Presiona COMENZAR."])
	_agregar_seccion(vbox, ":: MECANICA ::", ["Responde preguntas cada turno.", "Acierto = lanza ficha.", "Fallo = pierdes turno.", "20 segundos por pregunta."])
	_agregar_seccion(vbox, ":: PODERES (racha de 2) ::", ["[BOMBA] Destruye ficha enemiga.", "[HIELO] Congela una columna."])
	_agregar_seccion(vbox, ":: CONTROLES ::", ["[1] Normal  [2] Bomba  [3] Hielo", "[ESC] Cancelar  [P] Pausar"])
	_agregar_seccion(vbox, ":: MUSICA ::", ["Boton en esquina superior izquierda."])
	_agregar_seccion(vbox, ":: MULTIJUGADOR ONLINE ::", [
		"1. Presiona JUGAR > ONLINE.",
		"2. Un jugador crea la partida (HOST).",
		"3. El otro ingresa la IP y se une (CLIENTE).",
		"4. Ambos deben estar en la misma red.",
		"5. El HOST elige la categoria.",
		"6. Las preguntas se sincronizan automaticamente.",
		"Nota: Si un jugador se desconecta, la partida termina."
	])
	var btn_cerrar = Button.new()
	btn_cerrar.text = "CERRAR [X]"
	btn_cerrar.position = Vector2(400, 542)
	btn_cerrar.size = Vector2(200, 45)
	aplicar_boton_pixel(btn_cerrar, Color(0.35, 0.06, 0.06), Color(0.8, 0.2, 0.2), 12)
	btn_cerrar.pressed.connect(cb_cerrar)
	btn_cerrar.mouse_entered.connect(cb_hover)
	ventana.add_child(btn_cerrar)

func _agregar_seccion(contenedor, titulo, lineas):
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

func crear_panel_categorias(cb_confirmar, cb_volver, cb_hover, cb_categoria_sel):
	panel_categorias = Control.new()
	panel_categorias.name = "PanelCategorias"
	panel_categorias.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_categorias.hide()
	root.add_child(panel_categorias)
	
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
	btn_volver.pressed.connect(cb_volver)
	btn_volver.mouse_entered.connect(cb_hover)
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
		var btn_cat = Button.new()
		btn_cat.name = "BtnCat_" + clave
		btn_cat.text = "     " + categorias_disponibles[clave]
		btn_cat.position = Vector2(btn_x, y_offset + indice * (btn_height + btn_spacing))
		btn_cat.size = Vector2(btn_width, btn_height)
		aplicar_boton_pixel(btn_cat, Color(0.08, 0.08, 0.2), Color(0.2, 0.3, 0.6), 13)
		btn_cat.pressed.connect(cb_categoria_sel.bind(clave))
		btn_cat.mouse_entered.connect(cb_hover)
		ventana.add_child(btn_cat)
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
	btn_confirmar.pressed.connect(cb_confirmar)
	btn_confirmar.mouse_entered.connect(cb_hover)
	ventana.add_child(btn_confirmar)

func resaltar_categoria(clave_seleccionada: String):
	var ventana = panel_categorias.get_node("VentanaCategorias")
	for clave in categorias_disponibles.keys():
		var btn = ventana.get_node_or_null("BtnCat_" + clave)
		if btn:
			if clave == clave_seleccionada:
				aplicar_boton_pixel(btn, Color(0.1, 0.28, 0.5), Color(0.25, 0.65, 1), 13)
			else:
				aplicar_boton_pixel(btn, Color(0.08, 0.08, 0.2), Color(0.2, 0.3, 0.6), 13)

func actualizar_label_categoria(clave: String):
	var ventana = panel_categorias.get_node("VentanaCategorias")
	var label = ventana.get_node("LabelCategoriaSel")
	label.text = "> " + categorias_disponibles[clave]

func bloquear_categorias_cliente():
	var ventana = panel_categorias.get_node("VentanaCategorias")
	for child in ventana.get_children():
		if child is Button:
			child.hide()
	var lbl_sel = ventana.get_node_or_null("LabelCategoriaSel")
	if lbl_sel: lbl_sel.hide()
	var titulo = ventana.get_child(0)
	if titulo is Label:
		titulo.text = "\n\n\nESPERANDO AL HOST...\n\nEl Host esta eligiendo\nla categoria de la revancha."
		titulo.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
		TemaPixel.aplicar_fuente_label(titulo, 14)

func crear_panel_creditos(cb_hover):
	panel_creditos = Control.new()
	panel_creditos.name = "PanelCreditos"
	panel_creditos.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_creditos.hide()
	root.add_child(panel_creditos)
	
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
		"Repositorio", "https://github.com/davfcoder/LineUp4_Trivia.git", "",
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
	btn_cerrar_c.mouse_entered.connect(cb_hover)
	ventana.add_child(btn_cerrar_c)

func crear_panel_modo(cb_local, cb_online, cb_hover):
	panel_modo = Control.new()
	panel_modo.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_modo.hide()
	root.add_child(panel_modo)
	
	var fondo_oscuro = ColorRect.new()
	fondo_oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo_oscuro.color = Color(0, 0, 0, 0.8)
	panel_modo.add_child(fondo_oscuro)
	
	var ventana = Panel.new()
	ventana.position = Vector2(326, 150)
	ventana.size = Vector2(500, 350)
	ventana.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.05, 0.05, 0.16, 0.97), Color(0.2, 0.4, 0.85)
	))
	panel_modo.add_child(ventana)
	
	var titulo = Label.new()
	titulo.text = "MODO DE JUEGO"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(0, 25)
	titulo.size = Vector2(500, 40)
	TemaPixel.aplicar_fuente_label(titulo, 18)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ventana.add_child(titulo)
	
	var btn_local = Button.new()
	btn_local.text = "LOCAL (1 VS 1)"
	btn_local.position = Vector2(75, 100)
	btn_local.size = Vector2(350, 60)
	aplicar_boton_pixel(btn_local, Color(0.08, 0.35, 0.15), Color(0.2, 0.8, 0.3), 16)
	btn_local.pressed.connect(cb_local)
	btn_local.mouse_entered.connect(cb_hover)
	ventana.add_child(btn_local)
	
	var btn_online = Button.new()
	btn_online.text = "ONLINE (MULTIJUGADOR)"
	btn_online.position = Vector2(75, 180)
	btn_online.size = Vector2(350, 60)
	aplicar_boton_pixel(btn_online, Color(0.1, 0.2, 0.4), Color(0.3, 0.5, 0.9), 16)
	btn_online.pressed.connect(cb_online)
	btn_online.mouse_entered.connect(cb_hover)
	ventana.add_child(btn_online)
	
	var btn_volver = Button.new()
	btn_volver.text = "< VOLVER"
	btn_volver.position = Vector2(175, 270)
	btn_volver.size = Vector2(150, 45)
	aplicar_boton_pixel(btn_volver, Color(0.35, 0.1, 0.1), Color(0.8, 0.3, 0.3), 12)
	btn_volver.pressed.connect(func(): panel_modo.hide())
	btn_volver.mouse_entered.connect(cb_hover)
	ventana.add_child(btn_volver)

func crear_panel_online(cb_crear, cb_unirse, cb_volver, cb_hover):
	panel_online = Control.new()
	panel_online.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_online.hide()
	root.add_child(panel_online)
	
	var fondo_oscuro = ColorRect.new()
	fondo_oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo_oscuro.color = Color(0, 0, 0, 0.85)
	panel_online.add_child(fondo_oscuro)
	
	var ventana = Panel.new()
	ventana.position = Vector2(276, 120)
	ventana.size = Vector2(600, 420)
	ventana.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.05, 0.05, 0.16, 0.97), Color(0.2, 0.4, 0.85)
	))
	panel_online.add_child(ventana)
	
	var titulo = Label.new()
	titulo.text = "SALA MULTIJUGADOR"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(0, 20)
	titulo.size = Vector2(600, 40)
	TemaPixel.aplicar_fuente_label(titulo, 18)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ventana.add_child(titulo)
	
	var btn_host = Button.new()
	btn_host.text = "[1] CREAR PARTIDA (HOST)"
	btn_host.position = Vector2(100, 80)
	btn_host.size = Vector2(400, 60)
	aplicar_boton_pixel(btn_host, Color(0.3, 0.1, 0.3), Color(0.8, 0.3, 0.8), 14)
	btn_host.pressed.connect(cb_crear)
	btn_host.mouse_entered.connect(cb_hover)
	ventana.add_child(btn_host)
	
	var separador = Label.new()
	separador.text = "- O INGRESA LA IP DE UN AMIGO -"
	separador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	separador.position = Vector2(0, 160)
	separador.size = Vector2(600, 20)
	TemaPixel.aplicar_fuente_label(separador, 10)
	separador.add_theme_color_override("font_color", Color(0.4, 0.5, 0.7))
	ventana.add_child(separador)
	
	input_ip = LineEdit.new()
	input_ip.placeholder_text = "Ejemplo: 127.0.0.1"
	input_ip.alignment = HORIZONTAL_ALIGNMENT_CENTER
	input_ip.position = Vector2(150, 195)
	input_ip.size = Vector2(300, 50)
	var estilo_input = StyleBoxFlat.new()
	estilo_input.bg_color = Color(0.02, 0.02, 0.08)
	estilo_input.border_width_left = 2
	estilo_input.border_width_right = 2
	estilo_input.border_width_top = 2
	estilo_input.border_width_bottom = 2
	estilo_input.border_color = Color(0.3, 0.5, 0.9)
	input_ip.add_theme_stylebox_override("normal", estilo_input)
	input_ip.add_theme_stylebox_override("focus", estilo_input)
	input_ip.add_theme_color_override("font_color", Color(1, 1, 1))
	ventana.add_child(input_ip)
	
	var btn_join = Button.new()
	btn_join.text = "[2] UNIRSE (CLIENTE)"
	btn_join.position = Vector2(150, 260)
	btn_join.size = Vector2(300, 55)
	aplicar_boton_pixel(btn_join, Color(0.1, 0.3, 0.3), Color(0.2, 0.8, 0.8), 14)
	btn_join.pressed.connect(cb_unirse)
	btn_join.mouse_entered.connect(cb_hover)
	ventana.add_child(btn_join)
	
	label_estado_red = Label.new()
	label_estado_red.text = "Esperando accion..."
	label_estado_red.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_estado_red.position = Vector2(0, 330)
	label_estado_red.size = Vector2(600, 20)
	TemaPixel.aplicar_fuente_label(label_estado_red, 10)
	label_estado_red.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	ventana.add_child(label_estado_red)
	
	var btn_volver = Button.new()
	btn_volver.text = "< VOLVER"
	btn_volver.position = Vector2(225, 365)
	btn_volver.size = Vector2(150, 40)
	aplicar_boton_pixel(btn_volver, Color(0.35, 0.1, 0.1), Color(0.8, 0.3, 0.3), 11)
	btn_volver.pressed.connect(cb_volver)
	btn_volver.mouse_entered.connect(cb_hover)
	ventana.add_child(btn_volver)

func actualizar_estado_red(texto: String, color: Color):
	label_estado_red.text = texto
	label_estado_red.add_theme_color_override("font_color", color)

func obtener_ip() -> String:
	var ip = input_ip.text.strip_edges()
	return ip if ip != "" else "127.0.0.1"
