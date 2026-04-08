class_name HudView
extends RefCounted

const TemaPixel = preload("res://efectos/tema_pixel.gd")

var capa_ui: Node
var tablero_visual: Node

var panel_poderes = null
var label_inventario_j1 = null
var label_inventario_j2 = null
var boton_bomba = null
var boton_hielo = null
var boton_normal = null
var boton_cancelar = null
var label_poder_activo = null
var label_turno = null
var label_notificacion = null
var boton_reiniciar = null

func configurar(_capa_ui: Node, _tablero_visual: Node):
	capa_ui = _capa_ui
	tablero_visual = _tablero_visual

func enlazar_labels(_label_inventario_j1, _label_inventario_j2, _label_turno):
	label_inventario_j1 = _label_inventario_j1
	label_inventario_j2 = _label_inventario_j2
	label_turno = _label_turno

func aplicar_boton_pixel_juego(boton, color_fondo, color_borde, tam: int = 11):
	var estilos = TemaPixel.crear_boton_pixel(color_fondo, color_borde)
	boton.add_theme_stylebox_override("normal", estilos["normal"])
	boton.add_theme_stylebox_override("hover", estilos["hover"])
	boton.add_theme_stylebox_override("pressed", estilos["pressed"])
	boton.add_theme_color_override("font_color", Color(1, 1, 1))
	boton.add_theme_color_override("font_hover_color", Color(1, 1, 0.7))
	TemaPixel.aplicar_fuente_boton(boton, tam)

func crear_notificacion():
	label_notificacion = Label.new()
	label_notificacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_notificacion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_notificacion.position = Vector2(226, 65)
	label_notificacion.size = Vector2(700, 45)
	TemaPixel.aplicar_fuente_label(label_notificacion, 13)
	label_notificacion.add_theme_color_override("font_color", Color(1, 1, 0.3))
	label_notificacion.modulate.a = 0
	label_notificacion.z_index = 30
	capa_ui.add_child(label_notificacion)

func mostrar_notificacion(texto: String):
	label_notificacion.text = texto
	if label_notificacion.has_meta("tween"):
		var tweens_previos = label_notificacion.get_meta("tween")
		if tweens_previos and tweens_previos.is_valid():
			tweens_previos.kill()

	if label_notificacion.is_inside_tree():
		var tween = capa_ui.create_tween()
		label_notificacion.set_meta("tween", tween)
		tween.tween_property(label_notificacion, "modulate:a", 1.0, 0.2)
		tween.tween_interval(2.0)
		tween.tween_property(label_notificacion, "modulate:a", 0.0, 0.4)

func crear_interfaz_poderes(
	callback_normal: Callable,
	callback_bomba: Callable,
	callback_hielo: Callable,
	callback_cancelar: Callable,
	callback_reiniciar: Callable,
	callback_hover: Callable
):
	panel_poderes = Panel.new()
	panel_poderes.position = Vector2(220, 5)
	panel_poderes.size = Vector2(720, 50)
	panel_poderes.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.1, 0.1, 0.2, 0.95),
		Color(0.3, 0.4, 0.7)
	))
	capa_ui.add_child(panel_poderes)

	var boton_ancho = 140
	var boton_alto = 34
	var margen_y = 8
	var inicio_x = 8
	var separacion = 8

	boton_normal = Button.new()
	boton_normal.text = "[1] NORMAL"
	boton_normal.position = Vector2(inicio_x, margen_y)
	boton_normal.size = Vector2(boton_ancho, boton_alto)
	aplicar_boton_pixel_juego(boton_normal, Color(0.1, 0.3, 0.15), Color(0.2, 0.7, 0.3), 9)
	boton_normal.pressed.connect(callback_normal)
	boton_normal.mouse_entered.connect(callback_hover)
	panel_poderes.add_child(boton_normal)

	boton_bomba = Button.new()
	boton_bomba.text = "[2] BOMBA"
	boton_bomba.position = Vector2(inicio_x + (boton_ancho + separacion), margen_y)
	boton_bomba.size = Vector2(boton_ancho, boton_alto)
	aplicar_boton_pixel_juego(boton_bomba, Color(0.35, 0.15, 0.05), Color(0.9, 0.4, 0.1), 9)
	boton_bomba.pressed.connect(callback_bomba)
	boton_bomba.mouse_entered.connect(callback_hover)
	panel_poderes.add_child(boton_bomba)

	boton_hielo = Button.new()
	boton_hielo.text = "[3] HIELO"
	boton_hielo.position = Vector2(inicio_x + (boton_ancho + separacion) * 2, margen_y)
	boton_hielo.size = Vector2(boton_ancho, boton_alto)
	aplicar_boton_pixel_juego(boton_hielo, Color(0.1, 0.2, 0.4), Color(0.3, 0.7, 1), 9)
	boton_hielo.pressed.connect(callback_hielo)
	boton_hielo.mouse_entered.connect(callback_hover)
	panel_poderes.add_child(boton_hielo)

	boton_cancelar = Button.new()
	boton_cancelar.text = "[ESC]"
	boton_cancelar.position = Vector2(inicio_x + (boton_ancho + separacion) * 3, margen_y)
	boton_cancelar.size = Vector2(90, boton_alto)
	aplicar_boton_pixel_juego(boton_cancelar, Color(0.3, 0.1, 0.1), Color(0.8, 0.3, 0.3), 9)
	boton_cancelar.pressed.connect(callback_cancelar)
	boton_cancelar.mouse_entered.connect(callback_hover)
	boton_cancelar.hide()
	panel_poderes.add_child(boton_cancelar)

	label_poder_activo = Label.new()
	label_poder_activo.position = Vector2(inicio_x + (boton_ancho + separacion) * 3 + 100, margen_y + 5)
	label_poder_activo.size = Vector2(200, 30)
	TemaPixel.aplicar_fuente_label(label_poder_activo, 10)
	label_poder_activo.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	panel_poderes.add_child(label_poder_activo)

	boton_reiniciar = Button.new()
	boton_reiniciar.text = "JUGAR DE NUEVO"
	boton_reiniciar.position = Vector2(426, 550)
	boton_reiniciar.size = Vector2(300, 55)
	aplicar_boton_pixel_juego(boton_reiniciar, Color(0.08, 0.45, 0.15), Color(0.2, 1, 0.35), 14)
	boton_reiniciar.pressed.connect(callback_reiniciar)
	boton_reiniciar.mouse_entered.connect(callback_hover)
	boton_reiniciar.hide()
	capa_ui.add_child(boton_reiniciar)

	panel_poderes.hide()

func actualizar_inventario(jugador1_model, jugador2_model):
	if label_inventario_j1:
		label_inventario_j1.text = "P1 ROJO\nBOMBAS: " + str(jugador1_model.bombas) + "\nHIELOS: " + str(jugador1_model.hielos)
	if label_inventario_j2:
		label_inventario_j2.text = "P2 AMARILLO\nBOMBAS: " + str(jugador2_model.bombas) + "\nHIELOS: " + str(jugador2_model.hielos)

func actualizar_label_turno(turno_actual: int):
	if label_turno:
		var color_txt = "ROJO" if turno_actual == 1 else "AMARILLO"
		label_turno.text = "Turno: Jugador " + str(turno_actual) + " " + color_txt

func mostrar_botones_poder(es_multijugador: bool, turno_actual: int, mi_rol_multijugador: int, jugador_actual):
	panel_poderes.show()
	boton_cancelar.hide()
	label_poder_activo.show()

	if es_multijugador and turno_actual != mi_rol_multijugador:
		boton_normal.disabled = true
		boton_bomba.disabled = true
		boton_hielo.disabled = true
	else:
		boton_normal.disabled = false
		boton_bomba.disabled = not jugador_actual.tiene_bombas()
		boton_hielo.disabled = not jugador_actual.tiene_hielos()

	label_poder_activo.text = "Modo: NORMAL"
	label_poder_activo.add_theme_color_override("font_color", Color(0.5, 1, 0.5))

func ocultar_botones_poder():
	panel_poderes.hide()

func mostrar_modo_normal():
	label_poder_activo.text = "Modo: NORMAL"
	label_poder_activo.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	boton_cancelar.hide()
	label_poder_activo.show()

func mostrar_modo_bomba():
	label_poder_activo.text = "Poder: BOMBA"
	label_poder_activo.add_theme_color_override("font_color", Color(1, 0.5, 0.2))
	boton_cancelar.show()
	label_poder_activo.show()

func mostrar_modo_hielo():
	label_poder_activo.text = "Poder: HIELO"
	label_poder_activo.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
	boton_cancelar.show()
	label_poder_activo.show()

func mostrar_modo_lanzar_ficha():
	label_poder_activo.text = "Lanza tu ficha"
	label_poder_activo.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	boton_cancelar.hide()
	label_poder_activo.show()

func mostrar_modo_rival(poder_rival: String):
	label_poder_activo.text = "Modo: " + poder_rival
	
	if poder_rival == "BOMBA":
		label_poder_activo.add_theme_color_override("font_color", Color(1, 0.5, 0.2))
	elif poder_rival == "HIELO":
		label_poder_activo.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
	else:
		label_poder_activo.add_theme_color_override("font_color", Color(0.5, 1, 0.5))

func deshabilitar_botones_poder():
	boton_hielo.disabled = true
	boton_bomba.disabled = true

func actualizar_opacidad_jugadores(turno_actual: int):
	if turno_actual == 1:
		label_inventario_j1.modulate = Color(1, 1, 1, 1.0)
		label_inventario_j2.modulate = Color(1, 1, 1, 0.3)
	else:
		label_inventario_j1.modulate = Color(1, 1, 1, 0.3)
		label_inventario_j2.modulate = Color(1, 1, 1, 1.0)
