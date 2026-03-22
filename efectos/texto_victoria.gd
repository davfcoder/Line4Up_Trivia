extends Node2D

var tiempo = 0.0
var texto = "VICTORIA"
var color_texto = Color(1, 0.85, 0.1)
var letras_visibles = 0
var parpadeo = false

func _ready():
	z_index = 30

func _process(delta):
	tiempo += delta
	
	# Revelar letra por letra
	if letras_visibles < texto.length():
		letras_visibles = mini(int(tiempo / 0.12), texto.length())
	
	# Parpadeo después de completar
	if letras_visibles >= texto.length() and tiempo > texto.length() * 0.12 + 0.5:
		parpadeo = true
	
	queue_redraw()

func _draw():
	if texto.is_empty():
		return
	
	var tam_letra = 28.0
	var espacio = 6.0
	var total_ancho = texto.length() * (tam_letra + espacio)
	var inicio_x = -total_ancho / 2.0
	
	for i in range(mini(letras_visibles, texto.length())):
		var letra = texto[i]
		var x = inicio_x + i * (tam_letra + espacio)
		var y_offset = sin(tiempo * 3 + i * 0.5) * 4
		
		var alpha = 1.0
		if parpadeo:
			alpha = 0.6 + sin(tiempo * 5 + i * 0.3) * 0.4
		
		# Sombra
		dibujar_caracter_pixel(Vector2(x + 2, y_offset + 2), letra, Color(0, 0, 0, alpha * 0.5), tam_letra)
		# Letra
		dibujar_caracter_pixel(Vector2(x, y_offset), letra, Color(color_texto.r, color_texto.g, color_texto.b, alpha), tam_letra)

func dibujar_caracter_pixel(pos: Vector2, _caracter: String, color: Color, tam: float):
	# Dibuja un bloque estilizado por cada carácter
	var px = tam / 5.0
	draw_rect(Rect2(pos.x + px, pos.y, px * 3, px), color)
	draw_rect(Rect2(pos.x, pos.y + px, px * 5, px * 3), color)
	draw_rect(Rect2(pos.x + px, pos.y + px * 4, px * 3, px), color)
