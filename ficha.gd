extends TextureRect

var jugador = 1

# Cargar las texturas de las fichas
var textura_roja = preload("res://imagenes/ficha_roja70x70.png")
var textura_amarilla = preload("res://imagenes/ficha_amarilla70x70.png")

func configurar(num_jugador):
	jugador = num_jugador
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED  # Que llene todo el espacio
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	if jugador == 1:
		texture = textura_roja
	else:
		texture = textura_amarilla
		
	# --- AJUSTE DE TAMAÑO ---
	# Centramos el punto de pivote (basado en el tamaño actual de 72x72)
	pivot_offset = size / 2.0 
	
	# Reducimos su tamaño visual a un 90%
	scale = Vector2(0.9, 0.9)

func animar_caida(posicion_final_y):
	var tween = create_tween()
	# Animación de caída
	tween.tween_property(self, "position:y", posicion_final_y, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
