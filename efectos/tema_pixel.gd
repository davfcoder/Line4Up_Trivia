extends Node

# Fuente pixel (se carga una vez)
static var _fuente_pixel = null

static func obtener_fuente():
	if _fuente_pixel == null:
		_fuente_pixel = load("res://fuentes/PressStart2P-Regular.ttf")
	return _fuente_pixel

static func aplicar_fuente_label(label: Label, tam: int = 12):
	var fuente = obtener_fuente()
	if fuente:
		label.add_theme_font_override("font", fuente)
	label.add_theme_font_size_override("font_size", tam)

static func aplicar_fuente_boton(boton: Button, tam: int = 11):
	var fuente = obtener_fuente()
	if fuente:
		boton.add_theme_font_override("font", fuente)
	boton.add_theme_font_size_override("font_size", tam)

static func crear_panel_pixel(color_fondo: Color = Color(0.08, 0.08, 0.2, 0.95), color_borde: Color = Color(0.3, 0.5, 1.0)) -> StyleBoxFlat:
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = color_fondo
	estilo.border_width_bottom = 4
	estilo.border_width_top = 4
	estilo.border_width_left = 4
	estilo.border_width_right = 4
	estilo.border_color = color_borde
	# Sin bordes redondeados = más pixel art
	estilo.corner_radius_top_left = 0
	estilo.corner_radius_top_right = 0
	estilo.corner_radius_bottom_left = 0
	estilo.corner_radius_bottom_right = 0
	return estilo

static func crear_boton_pixel(color_fondo: Color, color_borde: Color) -> Dictionary:
	var normal = StyleBoxFlat.new()
	normal.bg_color = color_fondo
	normal.border_width_bottom = 4
	normal.border_width_top = 2
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_color = color_borde
	normal.corner_radius_top_left = 0
	normal.corner_radius_top_right = 0
	normal.corner_radius_bottom_left = 0
	normal.corner_radius_bottom_right = 0
	
	var hover = normal.duplicate()
	hover.bg_color = Color(color_fondo.r + 0.12, color_fondo.g + 0.12, color_fondo.b + 0.12)
	hover.border_color = Color(color_borde.r + 0.15, color_borde.g + 0.15, color_borde.b + 0.15)
	
	var pressed = normal.duplicate()
	pressed.bg_color = Color(color_fondo.r - 0.05, color_fondo.g - 0.05, color_fondo.b - 0.05)
	pressed.border_width_bottom = 2
	pressed.border_width_top = 4
	
	return {"normal": normal, "hover": hover, "pressed": pressed}
