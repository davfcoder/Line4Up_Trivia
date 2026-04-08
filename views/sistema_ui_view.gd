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
