extends Node2D

var tiempo = 0.0
var duracion = 0.55
var particulas = []

func _ready():
	z_index = 20
	for i in range(24):
		var angulo = TAU * i / 24.0 + randf_range(-0.15, 0.15)
		particulas.append({
			"dir": Vector2(cos(angulo), sin(angulo)),
			"vel": randf_range(90, 240),
			"tam": randf_range(5.0, 11.0),
			"tipo": randi() % 4
		})

func _process(delta):
	tiempo += delta
	if tiempo >= duracion:
		queue_free()
	queue_redraw()

func _draw():
	var t = clamp(tiempo / duracion, 0.0, 1.0)
	var alpha = 1.0 - t
	
	var colores = [
		Color(1, 0.95, 0.3, alpha),
		Color(1, 0.6, 0.1, alpha),
		Color(1, 0.2, 0.05, alpha),
		Color(0.35, 0.35, 0.35, alpha * 0.5)
	]
	
	# Flash central cuadrado (pixel art feel)
	if t < 0.15:
		var flash = lerp(28.0, 4.0, t / 0.15)
		draw_rect(Rect2(-flash / 2, -flash / 2, flash, flash), Color(1, 1, 0.9, 1.0 - t * 6.5))
	
	# Anillo de fuego expandiéndose (cuadrado)
	if t > 0.05 and t < 0.4:
		var ring = lerp(12.0, 50.0, (t - 0.05) / 0.35)
		var ring_a = 1.0 - (t - 0.05) / 0.35
		draw_rect(Rect2(-ring / 2, -ring / 2, ring, ring), Color(1, 0.5, 0.1, ring_a * 0.5), false, 3.0)
	
	# Partículas cuadradas (pixel art)
	for p in particulas:
		var pos = p["dir"] * p["vel"] * t
		var s = p["tam"] * (1.0 - t * 0.6)
		if s > 0.5:
			draw_rect(Rect2(pos.x - s / 2, pos.y - s / 2, s, s), colores[p["tipo"]])
	
	# Chispas pequeñas adicionales
	if t < 0.35:
		for i in range(8):
			var ang = TAU * i / 8.0
			var dist = 15.0 + t * 180
			var spark_pos = Vector2(cos(ang), sin(ang)) * dist
			var spark_a = clamp(1.0 - t * 3, 0, 1)
			draw_rect(Rect2(spark_pos.x - 2, spark_pos.y - 2, 4, 4), Color(1, 0.9, 0.3, spark_a))
