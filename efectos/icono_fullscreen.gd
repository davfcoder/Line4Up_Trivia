class_name IconoFullscreen
extends Control

var is_fullscreen = false

func actualizar_estado(estado):
	is_fullscreen = estado
	queue_redraw()

func _draw():
	var c = Color(1, 1, 1, 0.9)
	if not is_fullscreen:
		draw_rect(Rect2(12, 12, 9, 3), c); draw_rect(Rect2(12, 12, 3, 9), c)
		draw_rect(Rect2(24, 12, 9, 3), c); draw_rect(Rect2(30, 12, 3, 9), c)
		draw_rect(Rect2(12, 30, 9, 3), c); draw_rect(Rect2(12, 24, 3, 9), c)
		draw_rect(Rect2(24, 30, 9, 3), c); draw_rect(Rect2(30, 24, 3, 9), c)
	else:
		draw_rect(Rect2(13, 19, 9, 3), c); draw_rect(Rect2(19, 13, 3, 9), c)
		draw_rect(Rect2(23, 19, 9, 3), c); draw_rect(Rect2(23, 13, 3, 9), c)
		draw_rect(Rect2(13, 23, 9, 3), c); draw_rect(Rect2(19, 23, 3, 9), c)
		draw_rect(Rect2(23, 23, 9, 3), c); draw_rect(Rect2(23, 23, 3, 9), c)
