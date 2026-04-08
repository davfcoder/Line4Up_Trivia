class_name PausaView
extends RefCounted

const TemaPixel = preload("res://efectos/tema_pixel.gd")
const IconoPixel = preload("res://efectos/icono_pixel.gd")

var capa_ui
var panel_pausa = null
var boton_pausa = null

func configurar(_capa_ui):
	capa_ui = _capa_ui

func crear_menu_pausa(
	callback_continuar: Callable,
	callback_reiniciar: Callable,
	callback_menu: Callable,
	callback_toggle_pausa: Callable,
	callback_hover: Callable
):
	panel_pausa = Control.new()
	panel_pausa.name = "PanelPausa"
	panel_pausa.z_index = 100
	panel_pausa.hide()
	capa_ui.add_child(panel_pausa)
	
	var fondo = ColorRect.new()
	fondo.position = Vector2(0, 0)
	fondo.size = Vector2(1152, 648)
	fondo.color = Color(0, 0, 0, 0.8)
	panel_pausa.add_child(fondo)
	
	var ventana = Panel.new()
	ventana.position = Vector2(376, 150)
	ventana.size = Vector2(400, 350)
	ventana.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.06, 0.06, 0.18, 0.98),
		Color(0.3, 0.45, 0.8)
	))
	panel_pausa.add_child(ventana)
	
	var titulo = Label.new()
	titulo.text = "PAUSA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(100, 25)
	titulo.size = Vector2(200, 40)
	TemaPixel.aplicar_fuente_label(titulo, 24)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ventana.add_child(titulo)
	
	var btn_continuar = Button.new()
	btn_continuar.text = "CONTINUAR"
	btn_continuar.position = Vector2(100, 95)
	btn_continuar.size = Vector2(200, 50)
	_aplicar_boton_pixel(btn_continuar, Color(0.08, 0.4, 0.15), Color(0.2, 0.9, 0.3), 12)
	btn_continuar.pressed.connect(callback_continuar)
	btn_continuar.mouse_entered.connect(callback_hover)
	ventana.add_child(btn_continuar)
	
	var btn_reiniciar_pausa = Button.new()
	btn_reiniciar_pausa.text = "REINICIAR"
	btn_reiniciar_pausa.position = Vector2(100, 165)
	btn_reiniciar_pausa.size = Vector2(200, 50)
	_aplicar_boton_pixel(btn_reiniciar_pausa, Color(0.35, 0.25, 0.05), Color(0.8, 0.6, 0.1), 12)
	btn_reiniciar_pausa.pressed.connect(callback_reiniciar)
	btn_reiniciar_pausa.mouse_entered.connect(callback_hover)
	ventana.add_child(btn_reiniciar_pausa)
	
	var btn_menu = Button.new()
	btn_menu.text = "MENU"
	btn_menu.position = Vector2(100, 235)
	btn_menu.size = Vector2(200, 50)
	_aplicar_boton_pixel(btn_menu, Color(0.4, 0.08, 0.08), Color(1, 0.3, 0.3), 12)
	btn_menu.pressed.connect(callback_menu)
	btn_menu.mouse_entered.connect(callback_hover)
	ventana.add_child(btn_menu)
	
	panel_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	
	boton_pausa = Button.new()
	boton_pausa.name = "BotonPausa"
	boton_pausa.text = ""
	boton_pausa.position = Vector2(10, 10)
	boton_pausa.size = Vector2(45, 45)
	boton_pausa.z_index = 50
	
	var estilos_pausa = TemaPixel.crear_boton_pixel(
		Color(0.12, 0.12, 0.25, 0.85),
		Color(0.35, 0.4, 0.7)
	)
	boton_pausa.add_theme_stylebox_override("normal", estilos_pausa["normal"])
	boton_pausa.add_theme_stylebox_override("hover", estilos_pausa["hover"])
	boton_pausa.add_theme_stylebox_override("pressed", estilos_pausa["pressed"])
	boton_pausa.pressed.connect(callback_toggle_pausa)
	boton_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	boton_pausa.mouse_entered.connect(callback_hover)
	capa_ui.add_child(boton_pausa)
	
	var icono_pausa = IconoPixel.crear("pausa", 28.0)
	icono_pausa.position = Vector2(8, 8)
	boton_pausa.add_child(icono_pausa)

func mostrar_panel():
	if panel_pausa:
		panel_pausa.show()

func ocultar_panel():
	if panel_pausa:
		panel_pausa.hide()

func ocultar_boton_pausa():
	if boton_pausa:
		boton_pausa.hide()

func obtener_boton_pausa():
	return boton_pausa

func _aplicar_boton_pixel(boton, color_fondo, color_borde, tam: int = 11):
	var estilos = TemaPixel.crear_boton_pixel(color_fondo, color_borde)
	boton.add_theme_stylebox_override("normal", estilos["normal"])
	boton.add_theme_stylebox_override("hover", estilos["hover"])
	boton.add_theme_stylebox_override("pressed", estilos["pressed"])
	boton.add_theme_color_override("font_color", Color(1, 1, 1))
	boton.add_theme_color_override("font_hover_color", Color(1, 1, 0.7))
	TemaPixel.aplicar_fuente_boton(boton, tam)
