extends Control

var cristales = []

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 8
	for i in range(5):
		cristales.append({
			"pos": Vector2(randf_range(10, size.x - 10), randf_range(10, size.y - 10)),
			"tam": randf_range(4, 8)
		})
	queue_redraw()

func _draw():
	# Capa azul semitransparente
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.45, 0.8, 1.0, 0.25))
	
	# Borde de escarcha (pixelado)
	var escarcha_color = Color(0.7, 0.92, 1.0, 0.5)
	# Borde superior
	for x in range(0, int(size.x), 6):
		var h = randi_range(2, 7)
		draw_rect(Rect2(x, 0, 5, h), escarcha_color)
	# Borde inferior
	for x in range(0, int(size.x), 6):
		var h = randi_range(2, 7)
		draw_rect(Rect2(x, size.y - h, 5, h), escarcha_color)
	# Borde izquierdo
	for y in range(0, int(size.y), 6):
		var w = randi_range(2, 6)
		draw_rect(Rect2(0, y, w, 5), escarcha_color)
	# Borde derecho
	for y in range(0, int(size.y), 6):
		var w = randi_range(2, 6)
		draw_rect(Rect2(size.x - w, y, w, 5), escarcha_color)
	
	# Cristales de hielo (pixel art)
	for c in cristales:
		var p = c["pos"]
		var t = c["tam"]
		var cc = Color(0.85, 0.95, 1.0, 0.7)
		# Cruz de cristal
		draw_rect(Rect2(p.x - t / 2, p.y - 1, t, 3), cc)
		draw_rect(Rect2(p.x - 1, p.y - t / 2, 3, t), cc)
		# Diagonales pequeñas
		var d = t * 0.35
		draw_rect(Rect2(p.x - d, p.y - d, 3, 3), cc)
		draw_rect(Rect2(p.x + d - 2, p.y - d, 3, 3), cc)
		draw_rect(Rect2(p.x - d, p.y + d - 2, 3, 3), cc)
		draw_rect(Rect2(p.x + d - 2, p.y + d - 2, 3, 3), cc)
	
	# Puntos de brillo
	var brillo = Color(1, 1, 1, 0.6)
	draw_rect(Rect2(8, 8, 3, 3), brillo)
	draw_rect(Rect2(size.x - 14, 12, 3, 3), brillo)
	draw_rect(Rect2(size.x / 2, size.y / 2 - 5, 2, 2), brillo)
