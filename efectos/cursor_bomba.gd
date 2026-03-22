extends Node2D

var tiempo = 0.0

func _process(delta):
	tiempo += delta
	queue_redraw()

func _draw():
	# Cuerpo de la bomba (círculo pixelado)
	var negro = Color(0.15, 0.15, 0.15)
	var gris_oscuro = Color(0.25, 0.25, 0.25)
	var brillo = Color(0.4, 0.4, 0.4)
	var rojo = Color(1, 0.3, 0.1)
	var naranja = Color(1, 0.7, 0.1)
	var amarillo = Color(1, 1, 0.3)
	
	# Cuerpo circular (cuadrados para pixel art)
	var cx = -14.0
	var cy = -10.0
	# Fila por fila de la bomba (8x8 aprox)
	draw_rect(Rect2(cx + 4, cy + 0, 12, 4), negro)
	draw_rect(Rect2(cx + 0, cy + 4, 20, 4), negro)
	draw_rect(Rect2(cx + 0, cy + 8, 20, 4), negro)
	draw_rect(Rect2(cx + 0, cy + 12, 20, 4), negro)
	draw_rect(Rect2(cx + 4, cy + 16, 12, 4), negro)
	
	# Brillo
	draw_rect(Rect2(cx + 4, cy + 4, 4, 4), gris_oscuro)
	draw_rect(Rect2(cx + 4, cy + 4, 2, 2), brillo)
	
	# Mecha
	draw_rect(Rect2(cx + 8, cy - 4, 4, 5), Color(0.45, 0.3, 0.15))
	draw_rect(Rect2(cx + 10, cy - 8, 3, 5), Color(0.45, 0.3, 0.15))
	
	# Chispa animada
	var chispa_offset = sin(tiempo * 12) * 2
	draw_rect(Rect2(cx + 12 + chispa_offset, cy - 11, 3, 3), amarillo)
	draw_rect(Rect2(cx + 10, cy - 12 + chispa_offset, 3, 3), naranja)
	draw_rect(Rect2(cx + 14, cy - 10, 2, 2), rojo)
