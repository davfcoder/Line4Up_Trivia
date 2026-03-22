extends Node2D

var tiempo = 0.0
var duracion = 0.7
var columna_x = 0.0
var columna_y = 0.0
var columna_alto = 0.0
var columna_ancho = 70.0
var copos = []

func iniciar(x, y, ancho, alto):
	columna_x = x
	columna_y = y
	columna_ancho = ancho
	columna_alto = alto
	z_index = 15
	
	# Crear copos que caen
	for i in range(20):
		copos.append({
			"x": randf_range(columna_x, columna_x + columna_ancho),
			"y": randf_range(columna_y - 30, columna_y),
			"vel_y": randf_range(150, 350),
			"tam": randf_range(3, 7),
			"delay": randf_range(0, 0.2)
		})

func _process(delta):
	tiempo += delta
	if tiempo >= duracion:
		queue_free()
	queue_redraw()

func _draw():
	var t = clamp(tiempo / duracion, 0.0, 1.0)
	
	# Barrido azul de arriba a abajo
	var barra_y = columna_y + columna_alto * t
	var barra_h = 8.0
	var barra_alpha = 1.0 - t
	if t < 0.9:
		draw_rect(
			Rect2(columna_x, barra_y - barra_h, columna_ancho, barra_h),
			Color(0.5, 0.85, 1.0, barra_alpha * 0.7)
		)
	
	# Copos cayendo
	for c in copos:
		if tiempo < c["delay"]:
			continue
		var ct = tiempo - c["delay"]
		var cy = c["y"] + c["vel_y"] * ct
		var alpha_c = clamp(1.0 - (ct / (duracion - c["delay"])), 0, 1)
		if cy < columna_y + columna_alto:
			draw_rect(
				Rect2(c["x"] - c["tam"] / 2, cy - c["tam"] / 2, c["tam"], c["tam"]),
				Color(0.8, 0.95, 1.0, alpha_c)
			)
	
	# Flash general azul que se desvanece
	if t < 0.3:
		draw_rect(
			Rect2(columna_x, columna_y, columna_ancho, columna_alto),
			Color(0.5, 0.85, 1.0, 0.3 * (1.0 - t / 0.3))
		)
