extends Control

var tipo = "pausa"
var color_icono = Color(1, 1, 1)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw():
	match tipo:
		"pausa":
			_dibujar_pausa()
		"sonido_on":
			_dibujar_sonido_on()
		"sonido_off":
			_dibujar_sonido_off()
		"bomba_mini":
			_dibujar_bomba_mini()
		"hielo_mini":
			_dibujar_hielo_mini()
		"ficha_roja":
			_dibujar_ficha(Color(0.9, 0.15, 0.15))
		"ficha_amarilla":
			_dibujar_ficha(Color(1.0, 0.85, 0.0))
		"corona":
			_dibujar_corona()
		"reloj":
			_dibujar_reloj()
		"equis":
			_dibujar_equis()
		"check":
			_dibujar_check()
		"cat_ingles":
			_dibujar_cat_ingles()
		"cat_cultura":
			_dibujar_cat_cultura()
		"cat_programacion":
			_dibujar_cat_programacion()
		"cat_ciencias":
			_dibujar_cat_ciencias()
		"cat_historia":
			_dibujar_cat_historia()
		"info":
			_dibujar_info()
		

func _dibujar_pausa():
	var px = size.x / 24.0
	# Dos barras verticales
	draw_rect(Rect2(6 * px, 4 * px, 4 * px, 16 * px), color_icono)
	draw_rect(Rect2(14 * px, 4 * px, 4 * px, 16 * px), color_icono)

func _dibujar_sonido_on():
	var px = size.x / 24.0
	var c = color_icono
	# Altavoz
	draw_rect(Rect2(3*px, 9*px, 4*px, 6*px), c)
	draw_rect(Rect2(7*px, 7*px, 2*px, 10*px), c)
	draw_rect(Rect2(9*px, 5*px, 2*px, 14*px), c)
	# Ondas de sonido
	draw_rect(Rect2(13*px, 8*px, 2*px, 2*px), c)
	draw_rect(Rect2(13*px, 14*px, 2*px, 2*px), c)
	draw_rect(Rect2(15*px, 6*px, 2*px, 2*px), c)
	draw_rect(Rect2(15*px, 16*px, 2*px, 2*px), c)
	draw_rect(Rect2(17*px, 10*px, 2*px, 4*px), c)
	draw_rect(Rect2(19*px, 8*px, 2*px, 8*px), c)

func _dibujar_sonido_off():
	var px = size.x / 24.0
	var c = color_icono
	var r = Color(1, 0.3, 0.3)
	# Altavoz
	draw_rect(Rect2(3*px, 9*px, 4*px, 6*px), c)
	draw_rect(Rect2(7*px, 7*px, 2*px, 10*px), c)
	draw_rect(Rect2(9*px, 5*px, 2*px, 14*px), c)
	# X roja
	draw_rect(Rect2(14*px, 8*px, 2*px, 2*px), r)
	draw_rect(Rect2(16*px, 10*px, 2*px, 2*px), r)
	draw_rect(Rect2(18*px, 12*px, 2*px, 2*px), r)
	draw_rect(Rect2(18*px, 8*px, 2*px, 2*px), r)
	draw_rect(Rect2(16*px, 12*px, 2*px, 2*px), r)
	draw_rect(Rect2(14*px, 14*px, 2*px, 2*px), r)

func _dibujar_bomba_mini():
	var px = size.x / 24.0
	var n = Color(0.2, 0.2, 0.2)
	var g = Color(0.35, 0.35, 0.35)
	var o = Color(1, 0.6, 0.1)
	var y = Color(1, 1, 0.3)
	# Cuerpo
	draw_rect(Rect2(7*px, 10*px, 10*px, 4*px), n)
	draw_rect(Rect2(9*px, 8*px, 6*px, 2*px), n)
	draw_rect(Rect2(9*px, 14*px, 6*px, 2*px), n)
	draw_rect(Rect2(7*px, 10*px, 2*px, 2*px), g)
	# Mecha
	draw_rect(Rect2(11*px, 5*px, 2*px, 4*px), Color(0.5, 0.35, 0.15))
	# Chispa
	draw_rect(Rect2(10*px, 3*px, 2*px, 2*px), y)
	draw_rect(Rect2(12*px, 2*px, 2*px, 2*px), o)

func _dibujar_hielo_mini():
	var px = size.x / 24.0
	var az = Color(0.5, 0.85, 1.0)
	var bl = Color(0.85, 0.95, 1.0)
	# Cruz central
	draw_rect(Rect2(11*px, 4*px, 2*px, 16*px), az)
	draw_rect(Rect2(4*px, 11*px, 16*px, 2*px), az)
	# Diagonales
	draw_rect(Rect2(7*px, 7*px, 2*px, 2*px), az)
	draw_rect(Rect2(15*px, 7*px, 2*px, 2*px), az)
	draw_rect(Rect2(7*px, 15*px, 2*px, 2*px), az)
	draw_rect(Rect2(15*px, 15*px, 2*px, 2*px), az)
	# Centro
	draw_rect(Rect2(11*px, 11*px, 2*px, 2*px), bl)

func _dibujar_ficha(color: Color):
	var px = size.x / 24.0
	draw_rect(Rect2(6*px, 6*px, 12*px, 12*px), color)
	draw_rect(Rect2(8*px, 4*px, 8*px, 2*px), color)
	draw_rect(Rect2(8*px, 18*px, 8*px, 2*px), color)
	draw_rect(Rect2(4*px, 8*px, 2*px, 8*px), color)
	draw_rect(Rect2(18*px, 8*px, 2*px, 8*px), color)
	# Brillo
	draw_rect(Rect2(8*px, 8*px, 3*px, 3*px), Color(1, 1, 1, 0.35))

func _dibujar_corona():
	var px = size.x / 24.0
	var y_col = Color(1, 0.85, 0.1)
	# Base
	draw_rect(Rect2(4*px, 14*px, 16*px, 4*px), y_col)
	# Picos
	draw_rect(Rect2(4*px, 8*px, 2*px, 6*px), y_col)
	draw_rect(Rect2(11*px, 6*px, 2*px, 8*px), y_col)
	draw_rect(Rect2(18*px, 8*px, 2*px, 6*px), y_col)
	draw_rect(Rect2(7*px, 10*px, 2*px, 4*px), y_col)
	draw_rect(Rect2(15*px, 10*px, 2*px, 4*px), y_col)
	# Gemas
	draw_rect(Rect2(7*px, 15*px, 2*px, 2*px), Color(1, 0.2, 0.2))
	draw_rect(Rect2(11*px, 15*px, 2*px, 2*px), Color(0.2, 0.5, 1))
	draw_rect(Rect2(15*px, 15*px, 2*px, 2*px), Color(0.2, 0.9, 0.3))

func _dibujar_reloj():
	var px = size.x / 24.0
	var c = color_icono
	# Borde circular (cuadrado pixel)
	draw_rect(Rect2(6*px, 4*px, 12*px, 2*px), c)
	draw_rect(Rect2(6*px, 18*px, 12*px, 2*px), c)
	draw_rect(Rect2(4*px, 6*px, 2*px, 12*px), c)
	draw_rect(Rect2(18*px, 6*px, 2*px, 12*px), c)
	# Manecillas
	draw_rect(Rect2(11*px, 8*px, 2*px, 6*px), c)
	draw_rect(Rect2(13*px, 10*px, 4*px, 2*px), c)

func _dibujar_equis():
	var r = Color(1, 0.3, 0.3)
	var px = size.x / 24.0
	for i in range(6):
		draw_rect(Rect2((5 + i * 2)*px, (5 + i * 2)*px, 3*px, 3*px), r)
		draw_rect(Rect2((17 - i * 2)*px, (5 + i * 2)*px, 3*px, 3*px), r)

func _dibujar_check():
	var g = Color(0.2, 1, 0.3)
	var px = size.x / 24.0
	draw_rect(Rect2(5*px, 12*px, 2*px, 2*px), g)
	draw_rect(Rect2(7*px, 14*px, 2*px, 2*px), g)
	draw_rect(Rect2(9*px, 16*px, 2*px, 2*px), g)
	draw_rect(Rect2(11*px, 14*px, 2*px, 2*px), g)
	draw_rect(Rect2(13*px, 12*px, 2*px, 2*px), g)
	draw_rect(Rect2(15*px, 10*px, 2*px, 2*px), g)
	draw_rect(Rect2(17*px, 8*px, 2*px, 2*px), g)

func _dibujar_cat_ingles():
	var px = size.x / 24.0
	var c = Color(0.3, 0.7, 1)
	var w = Color(1, 1, 1)
	# Letra "A" pixel art
	draw_rect(Rect2(8*px, 4*px, 8*px, 2*px), c)
	draw_rect(Rect2(6*px, 6*px, 2*px, 14*px), c)
	draw_rect(Rect2(16*px, 6*px, 2*px, 14*px), c)
	draw_rect(Rect2(8*px, 12*px, 8*px, 2*px), c)
	# Burbuja de diálogo
	draw_rect(Rect2(4*px, 2*px, 16*px, 2*px), w)
	draw_rect(Rect2(2*px, 2*px, 2*px, 12*px), w)
	draw_rect(Rect2(20*px, 2*px, 2*px, 12*px), w)

func _dibujar_cat_cultura():
	var px = size.x / 24.0
	var az = Color(0.3, 0.5, 1)
	var vr = Color(0.2, 0.8, 0.3)
	# Globo terráqueo pixel
	draw_rect(Rect2(8*px, 4*px, 8*px, 2*px), az)
	draw_rect(Rect2(6*px, 6*px, 12*px, 2*px), az)
	draw_rect(Rect2(4*px, 8*px, 16*px, 2*px), az)
	draw_rect(Rect2(4*px, 10*px, 16*px, 2*px), az)
	draw_rect(Rect2(6*px, 12*px, 12*px, 2*px), az)
	draw_rect(Rect2(8*px, 14*px, 8*px, 2*px), az)
	# Continentes
	draw_rect(Rect2(8*px, 6*px, 4*px, 2*px), vr)
	draw_rect(Rect2(12*px, 8*px, 6*px, 2*px), vr)
	draw_rect(Rect2(6*px, 10*px, 4*px, 2*px), vr)
	draw_rect(Rect2(14*px, 12*px, 4*px, 2*px), vr)
	# Base
	draw_rect(Rect2(10*px, 16*px, 4*px, 2*px), Color(0.5, 0.5, 0.6))
	draw_rect(Rect2(8*px, 18*px, 8*px, 2*px), Color(0.5, 0.5, 0.6))

func _dibujar_cat_programacion():
	var px = size.x / 24.0
	var c = Color(0.3, 1, 0.4)
	# < símbolo
	draw_rect(Rect2(8*px, 6*px, 2*px, 2*px), c)
	draw_rect(Rect2(6*px, 8*px, 2*px, 2*px), c)
	draw_rect(Rect2(4*px, 10*px, 2*px, 2*px), c)
	draw_rect(Rect2(6*px, 12*px, 2*px, 2*px), c)
	draw_rect(Rect2(8*px, 14*px, 2*px, 2*px), c)
	# / símbolo
	draw_rect(Rect2(12*px, 14*px, 2*px, 2*px), Color(0.7, 0.7, 0.8))
	draw_rect(Rect2(11*px, 10*px, 2*px, 4*px), Color(0.7, 0.7, 0.8))
	draw_rect(Rect2(10*px, 6*px, 2*px, 4*px), Color(0.7, 0.7, 0.8))
	# > símbolo
	draw_rect(Rect2(14*px, 6*px, 2*px, 2*px), c)
	draw_rect(Rect2(16*px, 8*px, 2*px, 2*px), c)
	draw_rect(Rect2(18*px, 10*px, 2*px, 2*px), c)
	draw_rect(Rect2(16*px, 12*px, 2*px, 2*px), c)
	draw_rect(Rect2(14*px, 14*px, 2*px, 2*px), c)

func _dibujar_cat_ciencias():
	var px = size.x / 24.0
	var c = Color(0.4, 0.8, 1)
	var y_col = Color(1, 0.9, 0.2)
	# Matraz / frasco
	draw_rect(Rect2(10*px, 2*px, 4*px, 2*px), c)
	draw_rect(Rect2(10*px, 4*px, 4*px, 6*px), c)
	draw_rect(Rect2(8*px, 10*px, 8*px, 2*px), c)
	draw_rect(Rect2(6*px, 12*px, 12*px, 2*px), c)
	draw_rect(Rect2(4*px, 14*px, 16*px, 2*px), c)
	draw_rect(Rect2(6*px, 16*px, 12*px, 2*px), c)
	# Líquido
	draw_rect(Rect2(6*px, 14*px, 12*px, 2*px), Color(0.2, 0.9, 0.4, 0.7))
	draw_rect(Rect2(8*px, 12*px, 8*px, 2*px), Color(0.2, 0.9, 0.4, 0.5))
	# Burbujas
	draw_rect(Rect2(8*px, 10*px, 2*px, 2*px), y_col)
	draw_rect(Rect2(13*px, 12*px, 2*px, 2*px), y_col)

func _dibujar_cat_historia():
	var px = size.x / 24.0
	var c = Color(0.85, 0.7, 0.4)
	var d = Color(0.65, 0.5, 0.25)
	# Pergamino
	draw_rect(Rect2(6*px, 4*px, 12*px, 2*px), c)
	draw_rect(Rect2(4*px, 4*px, 2*px, 4*px), d)
	draw_rect(Rect2(18*px, 4*px, 2*px, 4*px), d)
	draw_rect(Rect2(6*px, 6*px, 12*px, 10*px), c)
	draw_rect(Rect2(4*px, 14*px, 2*px, 4*px), d)
	draw_rect(Rect2(18*px, 14*px, 2*px, 4*px), d)
	draw_rect(Rect2(6*px, 16*px, 12*px, 2*px), c)
	# Líneas de texto
	draw_rect(Rect2(8*px, 8*px, 8*px, 1*px), Color(0.4, 0.3, 0.15))
	draw_rect(Rect2(8*px, 10*px, 6*px, 1*px), Color(0.4, 0.3, 0.15))
	draw_rect(Rect2(8*px, 12*px, 7*px, 1*px), Color(0.4, 0.3, 0.15))

func _dibujar_info():
	var px = size.x / 24.0
	var c = color_icono
	# Círculo
	draw_rect(Rect2(8*px, 4*px, 8*px, 2*px), c)
	draw_rect(Rect2(6*px, 6*px, 12*px, 2*px), c)
	draw_rect(Rect2(4*px, 8*px, 16*px, 8*px), c)
	draw_rect(Rect2(6*px, 16*px, 12*px, 2*px), c)
	draw_rect(Rect2(8*px, 18*px, 8*px, 2*px), c)
	# Letra "i"
	var bg = Color(0.04, 0.04, 0.12)
	draw_rect(Rect2(10*px, 7*px, 4*px, 2*px), bg)
	draw_rect(Rect2(10*px, 10*px, 4*px, 6*px), bg)

static func crear(tipo_icono: String, tam: float = 24.0, color: Color = Color(1, 1, 1)) -> Control:
	var icono = Control.new()
	icono.set_script(load("res://efectos/icono_pixel.gd"))
	icono.tipo = tipo_icono
	icono.color_icono = color
	icono.custom_minimum_size = Vector2(tam, tam)
	icono.size = Vector2(tam, tam)
	icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icono
