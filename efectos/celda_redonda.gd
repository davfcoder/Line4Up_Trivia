class_name CeldaRedonda
extends Control

var color_celda = Color(0, 0, 0, 0)
var color_tablero = Color(0.08, 0.15, 0.4)

func set_color(nuevo_color):
	color_celda = nuevo_color
	queue_redraw()

func _draw():
	var w = size.x
	var h = size.y
	var radio = w / 2.0
	var centro = Vector2(radio, radio)
	var radio_agujero = radio - 6.0

	var puntos = PackedVector2Array()
	puntos.push_back(Vector2(0, 0))
	puntos.push_back(Vector2(w, 0))
	puntos.push_back(Vector2(w, h))
	puntos.push_back(Vector2(0, h))
	puntos.push_back(Vector2(0, 0))
	puntos.push_back(Vector2(radio, radio - radio_agujero))

	for i in range(32, -1, -1):
		var angle = (i / 32.0) * TAU - (PI / 2.0)
		puntos.push_back(centro + Vector2(cos(angle), sin(angle)) * radio_agujero)

	puntos.push_back(Vector2(0, 0))

	draw_colored_polygon(puntos, color_tablero)
	draw_arc(centro, radio_agujero, 0, TAU, 32, Color(0.02, 0.05, 0.1), 3.0, true)
	draw_arc(centro, radio_agujero + 2, 0, TAU, 32, Color(0.2, 0.4, 0.8), 1.0, true)

	var c_tornillo = Color(0.02, 0.04, 0.1)
	draw_rect(Rect2(4, 4, 3, 3), c_tornillo)
	draw_rect(Rect2(w - 7, 4, 3, 3), c_tornillo)
	draw_rect(Rect2(4, h - 7, 3, 3), c_tornillo)
	draw_rect(Rect2(w - 7, h - 7, 3, 3), c_tornillo)

	if color_celda.a > 0:
		draw_circle(centro, radio_agujero, color_celda)
