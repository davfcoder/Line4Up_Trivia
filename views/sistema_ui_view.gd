class_name SistemaUIView
extends RefCounted

const TemaPixel = preload("res://efectos/tema_pixel.gd")

var capa_ui
var boton_musica = null
var boton_fullscreen = null
var icono_fullscreen = null

func configurar(_capa_ui):
	capa_ui = _capa_ui

func crear_boton_musica(callback_toggle_musica: Callable):
	boton_musica = Global.crear_boton_musica(capa_ui, callback_toggle_musica)
	boton_musica.position = Vector2(60, 10)
	return boton_musica

func crear_boton_fullscreen(callback_toggle_fullscreen: Callable, callback_hover: Callable):
	boton_fullscreen = Button.new()
	boton_fullscreen.name = "BotonFullscreen"
	boton_fullscreen.position = Vector2(110, 10)
	boton_fullscreen.size = Vector2(45, 45)
	boton_fullscreen.z_index = 50
	
	var estilos_fs = TemaPixel.crear_boton_pixel(
		Color(0.12, 0.12, 0.25, 0.85),
		Color(0.35, 0.4, 0.7)
	)
	boton_fullscreen.add_theme_stylebox_override("normal", estilos_fs["normal"])
	boton_fullscreen.add_theme_stylebox_override("hover", estilos_fs["hover"])
	boton_fullscreen.add_theme_stylebox_override("pressed", estilos_fs["pressed"])
	
	boton_fullscreen.pressed.connect(callback_toggle_fullscreen)
	boton_fullscreen.mouse_entered.connect(callback_hover)
	
	icono_fullscreen = IconoFullscreen.new()
	icono_fullscreen.name = "IconoFS"
	icono_fullscreen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boton_fullscreen.add_child(icono_fullscreen)
	
	capa_ui.add_child(boton_fullscreen)
	return boton_fullscreen

func actualizar_icono_fullscreen(es_full: bool):
	if icono_fullscreen:
		icono_fullscreen.actualizar_estado(es_full)

func obtener_boton_musica():
	return boton_musica

func ocultar_boton_musica():
	if boton_musica:
		boton_musica.hide()

func mostrar_boton_musica():
	if boton_musica:
		boton_musica.show()

func ocultar_boton_fullscreen():
	if boton_fullscreen:
		boton_fullscreen.hide()

func mostrar_boton_fullscreen():
	if boton_fullscreen:
		boton_fullscreen.show()

var popup_actual: Node = null

func cerrar_popups():
	if popup_actual != null and is_instance_valid(popup_actual):
		popup_actual.queue_free()
		popup_actual = null

func _crear_base_popup(texto: String) -> Panel:
	cerrar_popups()
	var bg = ColorRect.new()
	bg.name = "PopupFondo"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.85)
	bg.z_index = 200
	capa_ui.add_child(bg)
	popup_actual = bg
	
	var panel = Panel.new()
	panel.size = Vector2(500, 220)
	panel.position = Vector2(1152/2.0 - 250, 648/2.0 - 110)
	panel.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(Color(0.1, 0.1, 0.18, 0.98), Color(0.3, 0.5, 0.8)))
	bg.add_child(panel)
	
	var lbl = Label.new()
	lbl.text = texto
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.size = Vector2(500, 130)
	TemaPixel.aplicar_fuente_label(lbl, 14)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	panel.add_child(lbl)
	
	return panel

func mostrar_popup_aviso(texto: String):
	_crear_base_popup(texto)

func mostrar_popup_pregunta(texto: String, cb_si: Callable, cb_no: Callable, aplicar_boton_callback: Callable):
	var panel = _crear_base_popup(texto)
	
	var btn_si = Button.new()
	btn_si.text = "SI, ACEPTO"
	btn_si.size = Vector2(180, 45)
	btn_si.position = Vector2(50, 140)
	aplicar_boton_callback.call(btn_si, Color(0.06, 0.38, 0.12), Color(0.15, 0.85, 0.25), 11)
	btn_si.pressed.connect(cb_si)
	panel.add_child(btn_si)
	
	var btn_no = Button.new()
	btn_no.text = "NO"
	btn_no.size = Vector2(180, 45)
	btn_no.position = Vector2(270, 140)
	aplicar_boton_callback.call(btn_no, Color(0.38, 0.06, 0.06), Color(0.85, 0.15, 0.15), 11)
	btn_no.pressed.connect(cb_no)
	panel.add_child(btn_no)
