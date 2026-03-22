extends Node2D

var tiempo = 0.0
var duracion = 4.0
var estrellas = []
var texto_timer = 0.0

func _ready():
	z_index = 25
	for i in range(30):
		estrellas.append({
			"x": randf_range(100, 1050),
			"y": randf_range(-50, -10),
			"vel": randf_range(80, 200),
			"tam": randf_range(4, 10),
			"color": [
				Color(1, 0.85, 0.1),
				Color(1, 0.3, 0.3),
				Color(0.3, 0.5, 1),
				Color(0.2, 1, 0.3),
				Color(1, 0.5, 1)
			].pick_random(),
			"delay": randf_range(0, 1.5),
			"rotacion": randf_range(-2, 2)
		})

func _process(delta):
	tiempo += delta
	texto_timer += delta
	if tiempo >= duracion:
		queue_free()
	queue_redraw()

func _draw():
	# Confeti pixel art cayendo
	for e in estrellas:
		if tiempo < e["delay"]:
			continue
		var t = tiempo - e["delay"]
		var y = e["y"] + e["vel"] * t
		var x = e["x"] + sin(t * e["rotacion"]) * 30
		var s = e["tam"]
		
		if y < 700:
			var alpha = clamp(1.0 - (t / (duracion - e["delay"])), 0, 1)
			var c = e["color"]
			c.a = alpha
			# Formas aleatorias pixel
			match randi() % 3:
				0:
					draw_rect(Rect2(x, y, s, s), c)
				1:
					draw_rect(Rect2(x, y, s * 1.5, s * 0.5), c)
				2:
					draw_rect(Rect2(x, y, s * 0.5, s * 1.5), c)
	
	# Destellos laterales
	if tiempo < 2.0:
		var flash_alpha = clamp(1.0 - tiempo / 2.0, 0, 1)
		for i in range(5):
			var bx = 200 + i * 180
			var by = 100 + sin(tiempo * 4 + i) * 50
			draw_rect(Rect2(bx, by, 6, 6), Color(1, 1, 0.5, flash_alpha * 0.6))
