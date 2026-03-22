extends Node2D

var estrellas = []
var estrellas_brillantes = []
var shooting_stars = []
var tiempo = 0.0
var nebulosas = []
var fichas_flotantes = []
var lineas_grid = []
var planetas = []

func _ready():
	z_index = -15
	
	# Estrellas pequeñas de varios colores
	for i in range(150):
		var color_star = [
			Color(0.8, 0.8, 1.0),
			Color(1.0, 0.9, 0.7),
			Color(0.7, 0.85, 1.0),
			Color(1.0, 0.75, 0.75),
			Color(0.75, 1.0, 0.8)
		].pick_random()
		estrellas.append({
			"pos": Vector2(randf_range(0, 1152), randf_range(0, 648)),
			"tam": randf_range(1, 3),
			"brillo": randf_range(0.15, 0.55),
			"color": color_star
		})
	
	# Estrellas que parpadean
	for i in range(30):
		estrellas_brillantes.append({
			"pos": Vector2(randf_range(0, 1152), randf_range(0, 648)),
			"tam": randf_range(2, 5),
			"vel": randf_range(1.5, 4.0),
			"offset": randf_range(0, TAU),
			"color": [Color(0.9, 0.9, 1), Color(1, 0.95, 0.7), Color(0.7, 0.8, 1)].pick_random()
		})
	
	# Nebulosas coloridas
	for i in range(5):
		nebulosas.append({
			"pos": Vector2(randf_range(50, 1100), randf_range(30, 618)),
			"radio": randf_range(100, 220),
			"color": [
				Color(0.2, 0.05, 0.4, 0.06),
				Color(0.05, 0.15, 0.4, 0.05),
				Color(0.3, 0.05, 0.2, 0.05),
				Color(0.05, 0.2, 0.35, 0.06),
				Color(0.15, 0.05, 0.35, 0.04)
			].pick_random()
		})
	
	# Fichas flotantes decorativas
	for i in range(8):
		fichas_flotantes.append({
			"pos": Vector2(randf_range(30, 1120), randf_range(30, 618)),
			"tam": randf_range(8, 18),
			"vel_x": randf_range(-12, 12),
			"vel_y": randf_range(-8, 8),
			"color": [Color(0.9, 0.15, 0.15, 0.12), Color(1, 0.85, 0.0, 0.12)].pick_random(),
			"fase": randf_range(0, TAU)
		})
	
	# Líneas de grid retro
	for i in range(0, 1160, 80):
		lineas_grid.append({"x": i, "vertical": true})
	for i in range(0, 656, 80):
		lineas_grid.append({"y": i, "vertical": false})
	
	# Planeta pequeño decorativo
	planetas.append({
		"pos": Vector2(920, 520),
		"radio": 35,
		"color": Color(0.15, 0.1, 0.35),
		"anillo": Color(0.3, 0.2, 0.5, 0.4)
	})
	planetas.append({
		"pos": Vector2(150, 100),
		"radio": 20,
		"color": Color(0.2, 0.12, 0.08),
		"anillo": Color(0.4, 0.25, 0.1, 0.3)
	})

func _process(delta):
	tiempo += delta
	
	# Estrellas fugaces
	if randi() % 120 == 0:
		shooting_stars.append({
			"pos": Vector2(randf_range(0, 800), randf_range(0, 150)),
			"vel": Vector2(randf_range(450, 800), randf_range(180, 350)),
			"vida": 0.0,
			"max_vida": randf_range(0.3, 0.7)
		})
	
	var a_quitar = []
	for s in shooting_stars:
		s["vida"] += delta
		s["pos"] += s["vel"] * delta
		if s["vida"] > s["max_vida"]:
			a_quitar.append(s)
	for s in a_quitar:
		shooting_stars.erase(s)
	
	# Mover fichas flotantes
	for f in fichas_flotantes:
		f["pos"].x += f["vel_x"] * delta
		f["pos"].y += f["vel_y"] * delta + sin(tiempo * 0.8 + f["fase"]) * 0.3
		# Wrap around
		if f["pos"].x < -20: f["pos"].x = 1172
		if f["pos"].x > 1172: f["pos"].x = -20
		if f["pos"].y < -20: f["pos"].y = 668
		if f["pos"].y > 668: f["pos"].y = -20
	
	queue_redraw()

func _draw():
	# Grid retro sutil
	for g in lineas_grid:
		if g.has("x"):
			draw_line(Vector2(g["x"], 0), Vector2(g["x"], 648), Color(0.1, 0.12, 0.25, 0.08), 1)
		else:
			draw_line(Vector2(0, g["y"]), Vector2(1152, g["y"]), Color(0.1, 0.12, 0.25, 0.08), 1)
	
	# Nebulosas
	for n in nebulosas:
		var pasos = 10
		for i in range(pasos):
			var r = n["radio"] * (1.0 - float(i) / pasos)
			var a = n["color"].a * (1.0 - float(i) / pasos) * 1.5
			var c = Color(n["color"].r, n["color"].g, n["color"].b, a)
			var bloques = int(r / 8)
			for bx in range(-bloques, bloques):
				for by in range(-bloques, bloques):
					if Vector2(bx, by).length() < bloques * (0.7 + sin(bx * 0.5 + by * 0.3) * 0.3):
						draw_rect(Rect2(n["pos"].x + bx * 8, n["pos"].y + by * 8, 8, 8), c)
	
	# Planetas
	for p in planetas:
		var r = p["radio"]
		var pos = p["pos"]
		# Cuerpo del planeta (cuadrados pixel)
		var bloques = int(r / 4)
		for bx in range(-bloques, bloques):
			for by in range(-bloques, bloques):
				if Vector2(bx, by).length() < bloques:
					var shade = 0.8 + (float(bx) / bloques) * 0.2
					var c = Color(p["color"].r * shade, p["color"].g * shade, p["color"].b * shade)
					draw_rect(Rect2(pos.x + bx * 4, pos.y + by * 4, 4, 4), c)
		# Anillo
		for i in range(-bloques - 4, bloques + 5):
			var ring_y = int(sin(float(i) / (bloques + 4) * PI * 0.3) * 3)
			draw_rect(Rect2(pos.x + i * 4, pos.y + r + ring_y, 4, 2), p["anillo"])
	
	# Estrellas pequeñas
	for e in estrellas:
		var c = Color(e["color"].r, e["color"].g, e["color"].b, e["brillo"])
		draw_rect(Rect2(e["pos"].x, e["pos"].y, e["tam"], e["tam"]), c)
	
	# Estrellas brillantes
	for e in estrellas_brillantes:
		var brillo = 0.3 + sin(tiempo * e["vel"] + e["offset"]) * 0.45
		var t = e["tam"]
		var p = e["pos"]
		var c = Color(e["color"].r, e["color"].g, e["color"].b, brillo)
		# Cruz pixel con brillo
		draw_rect(Rect2(p.x - 1, p.y - t, 2, t * 2), c)
		draw_rect(Rect2(p.x - t, p.y - 1, t * 2, 2), c)
		draw_rect(Rect2(p.x - 1, p.y - 1, 2, 2), Color(1, 1, 1, brillo * 1.2))
		# Diagonales pequeñas
		var d = t * 0.5
		draw_rect(Rect2(p.x - d, p.y - d, 1, 1), Color(1, 1, 1, brillo * 0.5))
		draw_rect(Rect2(p.x + d, p.y - d, 1, 1), Color(1, 1, 1, brillo * 0.5))
		draw_rect(Rect2(p.x - d, p.y + d, 1, 1), Color(1, 1, 1, brillo * 0.5))
		draw_rect(Rect2(p.x + d, p.y + d, 1, 1), Color(1, 1, 1, brillo * 0.5))
	
	# Fichas flotantes
	for f in fichas_flotantes:
		var p = f["pos"]
		var t = f["tam"]
		var pulse = 0.8 + sin(tiempo * 1.5 + f["fase"]) * 0.2
		var c = Color(f["color"].r, f["color"].g, f["color"].b, f["color"].a * pulse)
		# Ficha pixel (cuadrado redondeado)
		draw_rect(Rect2(p.x + 2, p.y, t - 4, t), c)
		draw_rect(Rect2(p.x, p.y + 2, t, t - 4), c)
		# Brillo
		draw_rect(Rect2(p.x + 3, p.y + 3, 3, 3), Color(1, 1, 1, c.a * 0.4))
	
	# Estrellas fugaces
	for s in shooting_stars:
		var alpha = 1.0 - s["vida"] / s["max_vida"]
		var p = s["pos"]
		for i in range(8):
			var trail_p = p - s["vel"].normalized() * i * 6
			var trail_a = alpha * (1.0 - float(i) / 8.0)
			var trail_c = Color(0.7, 0.8, 1, trail_a)
			draw_rect(Rect2(trail_p.x, trail_p.y, 4 - i * 0.3, 2), trail_c)
		draw_rect(Rect2(p.x, p.y, 5, 3), Color(1, 1, 1, alpha))
