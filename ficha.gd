extends TextureRect

var jugador = 1

# Cargar las texturas de las fichas
var textura_roja = preload("res://imagenes/ficha_roja70x70.png")
var textura_amarilla = preload("res://imagenes/ficha_amarilla70x70.png")

func configurar(num_jugador):
	jugador = num_jugador
	
	if jugador == 1:
		texture = textura_roja
	else:
		texture = textura_amarilla

func animar_caida(posicion_final_y):
	var tween = create_tween()
	tween.tween_property(self, "position:y", posicion_final_y, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

#extends Control
#
#var jugador = 1
#
#var color_j1 = Color(0.9, 0.1, 0.1)   # Rojo
#var color_j2 = Color(1.0, 0.85, 0.0)   # Amarillo
#
#func configurar(num_jugador):
	#jugador = num_jugador
	#queue_redraw()  # Forzar redibujo con el color correcto
#
#func _draw():
	#var radio = size.x / 2.0
	#var centro = Vector2(radio, radio)
	#var color_ficha = color_j1 if jugador == 1 else color_j2
	#
	## Círculo principal
	#draw_circle(centro, radio, color_ficha)
	#
	## Brillo interior (efecto 3D)
	#var color_brillo = Color(1, 1, 1, 0.3)
	#draw_circle(centro + Vector2(-radio * 0.2, -radio * 0.2), radio * 0.5, color_brillo)
	#
	## Borde oscuro
	#var color_borde = Color(0, 0, 0, 0.3)
	#draw_arc(centro, radio - 1, 0, TAU, 64, color_borde, 2.0)
#
#func animar_caida(posicion_final_y):
	#var tween = create_tween()
	#tween.tween_property(self, "position:y", posicion_final_y, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)	
