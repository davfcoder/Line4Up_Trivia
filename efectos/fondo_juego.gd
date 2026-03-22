extends Node2D

var tiempo = 0.0
var estrellas_dim = []
var circuitos = []
var particulas_flotantes = []
var naves = [] # Nuevo arreglo para las naves

func _ready():
	z_index = -15
	
	# Estrellas (ahora con colores más brillantes y vibrantes)
	for i in range(80):
		estrellas_dim.append({
			"pos": Vector2(randf_range(0, 1152), randf_range(0, 648)),
			"tam": randf_range(1, 3),
			"brillo": randf_range(0.3, 0.8), # Aumentado el brillo base
			"vel": randf_range(1, 3),
			"offset": randf_range(0, TAU),
			"color": [
				Color(0.8, 0.9, 1.0), # Blanco azulado brillante
				Color(1.0, 0.8, 0.4), # Amarillo brillante
				Color(0.5, 1.0, 0.8), # Verde cyan
				Color(1.0, 0.5, 0.8)  # Rosa neón
			].pick_random()
		})
	
	# Líneas de circuito (colores más saturados tipo Cyberpunk)
	for i in range(15):
		var start = Vector2(randf_range(0, 1152), randf_range(0, 648))
		var segmentos = []
		var pos_actual = start
		for j in range(randi_range(3, 8)):
			var dir = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)].pick_random()
			var largo = randf_range(40, 150)
			var fin = pos_actual + dir * largo
			segmentos.append({"from": pos_actual, "to": fin})
			pos_actual = fin
		circuitos.append({
			"segmentos": segmentos,
			"color": [
				Color(0.2, 0.8, 1.0, 0.25), # Cyan
				Color(0.8, 0.2, 0.9, 0.20), # Magenta
				Color(0.4, 0.9, 0.3, 0.22), # Verde lima
				Color(1.0, 0.4, 0.2, 0.20)  # Naranja
			].pick_random(),
			"pulso_offset": randf_range(0, TAU)
		})
	
	# Partículas flotantes (más coloridas)
	for i in range(12):
		particulas_flotantes.append({
			"pos": Vector2(randf_range(0, 1152), randf_range(0, 648)),
			"vel": Vector2(randf_range(-15, 15), randf_range(-10, 10)),
			"tam": randf_range(2, 5),
			"color": [
				Color(0.4, 0.8, 1.0, 0.3),
				Color(0.9, 0.4, 1.0, 0.25),
				Color(0.5, 1.0, 0.6, 0.25),
				Color(1.0, 0.8, 0.3, 0.2)
			].pick_random(),
			"fase": randf_range(0, TAU)
		})
		
	# Naves espaciales navegando
	for i in range(6): # Cantidad de naves
		var dir = Vector2(randf_range(-1, 1), randf_range(-0.5, 0.5)).normalized()
		naves.append({
			"pos": Vector2(randf_range(0, 1152), randf_range(0, 648)),
			"vel": dir * randf_range(40, 90), # Velocidad de las naves
			"color": [
				Color(0.1, 0.9, 0.9), # Cyan brillante
				Color(0.9, 0.1, 0.4), # Rojo rosado
				Color(0.9, 0.8, 0.1), # Amarillo
				Color(1.0, 1.0, 1.0)  # Blanco puro
			].pick_random(),
			"escala": randf_range(0.8, 1.5),
			"fase": randf_range(0, TAU)
		})

func _process(delta):
	tiempo += delta
	
	# Mover partículas
	for p in particulas_flotantes:
		p["pos"] += p["vel"] * delta
		p["pos"].y += sin(tiempo + p["fase"]) * 0.5
		if p["pos"].x < -20: p["pos"].x = 1172
		if p["pos"].x > 1172: p["pos"].x = -20
		if p["pos"].y < -20: p["pos"].y = 668
		if p["pos"].y > 668: p["pos"].y = -20

	# Mover naves espaciales
	for n in naves:
		n["pos"] += n["vel"] * delta
		# Movimiento suave ondulante para que no sea totalmente recto
		n["pos"].y += sin(tiempo * 2.0 + n["fase"]) * 0.3
		
		# Envolver pantalla (Screen wrap)
		if n["pos"].x < -50: n["pos"].x = 1200
		if n["pos"].x > 1200: n["pos"].x = -50
		if n["pos"].y < -50: n["pos"].y = 700
		if n["pos"].y > 700: n["pos"].y = -50

	queue_redraw()

func _draw():
	# Grid sutil
	var grid_alpha = 0.08 + sin(tiempo * 0.3) * 0.03
	for x in range(0, 1160, 60):
		for y in range(0, 648, 4):
			if (y / 4) % 3 == 0:
				draw_rect(Rect2(x, y, 1, 2), Color(0.2, 0.3, 0.6, grid_alpha))
	for y in range(0, 656, 60):
		for x in range(0, 1152, 4):
			if (x / 4) % 3 == 0:
				draw_rect(Rect2(x, y, 2, 1), Color(0.2, 0.3, 0.6, grid_alpha))
	
	# Circuitos con pulso
	for c in circuitos:
		var pulso = 0.7 + sin(tiempo * 0.8 + c["pulso_offset"]) * 0.3
		var col = c["color"]
		var draw_col = Color(col.r, col.g, col.b, col.a * pulso)
		
		for seg in c["segmentos"]:
			var f = seg["from"]
			var t = seg["to"]
			if abs(f.x - t.x) > abs(f.y - t.y):
				var min_x = min(f.x, t.x)
				var max_x = max(f.x, t.x)
				for px in range(int(min_x), int(max_x), 3):
					draw_rect(Rect2(px, f.y, 2, 2), draw_col)
			else:
				var min_y = min(f.y, t.y)
				var max_y = max(f.y, t.y)
				for py in range(int(min_y), int(max_y), 3):
					draw_rect(Rect2(f.x, py, 2, 2), draw_col)
		
		# Nodos brillantes en las esquinas
		for seg in c["segmentos"]:
			var node_pulse = 0.5 + sin(tiempo * 2 + c["pulso_offset"]) * 0.5
			var node_col = Color(col.r * 1.5, col.g * 1.5, col.b * 1.5, col.a * 2.5 * node_pulse)
			draw_rect(Rect2(seg["from"].x - 2, seg["from"].y - 2, 4, 4), node_col)
	
	# Estrellas tenues que parpadean
	for e in estrellas_dim:
		var b = e["brillo"] * (0.5 + sin(tiempo * e["vel"] + e["offset"]) * 0.5)
		var c = Color(e["color"].r, e["color"].g, e["color"].b, b)
		var p = e["pos"]
		var t = e["tam"]
		draw_rect(Rect2(p.x, p.y, t, t), c)
		# Cruz sutil en estrellas grandes
		if t > 2:
			draw_rect(Rect2(p.x - 1, p.y + t / 2, t + 2, 1), Color(c.r, c.g, c.b, b * 0.6))
			draw_rect(Rect2(p.x + t / 2, p.y - 1, 1, t + 2), Color(c.r, c.g, c.b, b * 0.6))
	
	# Partículas flotantes
	for p in particulas_flotantes:
		var pulse = 0.6 + sin(tiempo * 1.5 + p["fase"]) * 0.4
		var c = Color(p["color"].r, p["color"].g, p["color"].b, p["color"].a * pulse)
		var pos = p["pos"]
		var t = p["tam"]
		draw_rect(Rect2(pos.x, pos.y, t, t), c)
		# Estela
		draw_rect(Rect2(pos.x - p["vel"].x * 0.3, pos.y - p["vel"].y * 0.3, t * 0.7, t * 0.7), 
			Color(c.r, c.g, c.b, c.a * 0.5))
			
	# --- DIBUJAR NAVES ESPACIALES ---
	for n in naves:
		var angulo = n["vel"].angle()
		var s = n["escala"]
		var pos = n["pos"]
		
		# Puntos para formar un polígono tipo nave retro (flecha)
		var puntos_nave = PackedVector2Array()
		puntos_nave.push_back(pos + Vector2(12 * s, 0).rotated(angulo))      # Punta
		puntos_nave.push_back(pos + Vector2(-8 * s, 6 * s).rotated(angulo))  # Ala inferior
		puntos_nave.push_back(pos + Vector2(-4 * s, 0).rotated(angulo))      # Base trasera
		puntos_nave.push_back(pos + Vector2(-8 * s, -6 * s).rotated(angulo)) # Ala superior
		
		# Dibujar el cuerpo de la nave
		var col_nave = n["color"]
		draw_colored_polygon(puntos_nave, Color(col_nave.r, col_nave.g, col_nave.b, 0.8))
		
		# Dibujar el propulsor (fuego)
		var pulso_motor = randf_range(0.5, 1.0)
		var puntos_motor = PackedVector2Array()
		puntos_motor.push_back(pos + Vector2(-5 * s, 2 * s).rotated(angulo))
		puntos_motor.push_back(pos + Vector2(-12 * s * pulso_motor, 0).rotated(angulo)) # Llama
		puntos_motor.push_back(pos + Vector2(-5 * s, -2 * s).rotated(angulo))
		
		draw_colored_polygon(puntos_motor, Color(1.0, 0.6, 0.1, 0.9)) # Naranja brillante para el fuego
	
	# Bordes luminosos sutiles
	var borde_alpha = 0.06 + sin(tiempo * 0.5) * 0.03
	for x in range(0, 1152, 3):
		draw_rect(Rect2(x, 0, 2, 1), Color(0.3, 0.5, 0.8, borde_alpha))
		draw_rect(Rect2(x, 647, 2, 1), Color(0.3, 0.5, 0.8, borde_alpha))
