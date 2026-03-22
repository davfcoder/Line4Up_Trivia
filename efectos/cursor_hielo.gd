extends Node2D

var tiempo = 0.0

func _process(delta):
	tiempo += delta
	queue_redraw()

func _draw():
	var azul_claro = Color(0.6, 0.9, 1.0)
	var azul = Color(0.3, 0.7, 1.0)
	var azul_oscuro = Color(0.2, 0.5, 0.8)
	var blanco = Color(0.9, 0.95, 1.0)
	
	var cx = -12.0
	var cy = -12.0
	
	# Cubo de hielo pixel art
	# Cara frontal
	draw_rect(Rect2(cx + 2, cy + 6, 18, 16), azul)
	draw_rect(Rect2(cx + 2, cy + 6, 18, 2), azul_claro)
	draw_rect(Rect2(cx + 2, cy + 6, 2, 16), azul_claro)
	draw_rect(Rect2(cx + 18, cy + 6, 2, 16), azul_oscuro)
	draw_rect(Rect2(cx + 2, cy + 20, 18, 2), azul_oscuro)
	
	# Cara superior (perspectiva)
	draw_rect(Rect2(cx + 4, cy + 0, 18, 8), azul_claro)
	draw_rect(Rect2(cx + 4, cy + 0, 18, 2), blanco)
	
	# Brillos
	draw_rect(Rect2(cx + 6, cy + 10, 3, 3), blanco)
	draw_rect(Rect2(cx + 12, cy + 14, 2, 2), Color(0.8, 0.95, 1.0, 0.8))
	
	# Cristales animados alrededor
	var pulse = sin(tiempo * 6) * 0.5 + 0.5
	var spark_color = Color(0.8, 0.95, 1.0, pulse * 0.8)
	draw_rect(Rect2(cx - 4, cy + 2, 3, 3), spark_color)
	draw_rect(Rect2(cx + 22, cy + 10, 3, 3), spark_color)
	draw_rect(Rect2(cx + 10, cy + 24, 3, 3), spark_color)
	draw_rect(Rect2(cx + 20, cy - 2, 2, 2), spark_color)
