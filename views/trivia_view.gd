class_name TriviaView
extends RefCounted

const TemaPixel = preload("res://efectos/tema_pixel.gd")

var pantalla_pregunta
var texto_pregunta
var contenedor_botones
var texto_reloj

var barra_tiempo: ColorRect
var barra_fondo: ColorRect
var barra_ancho_max := 0.0
var ultimo_segundo_reloj = -1

func configurar(_pantalla_pregunta, _texto_pregunta, _contenedor_botones, _texto_reloj):
	pantalla_pregunta = _pantalla_pregunta
	texto_pregunta = _texto_pregunta
	contenedor_botones = _contenedor_botones
	texto_reloj = _texto_reloj
	crear_barra_tiempo()

func estilizar_pantalla_pregunta(aplicar_boton_callback: Callable):
	TemaPixel.aplicar_fuente_label(texto_pregunta, 15)
	texto_pregunta.add_theme_color_override("font_color", Color(0.9, 0.9, 1))
	TemaPixel.aplicar_fuente_label(texto_reloj, 23)
	texto_reloj.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	
	var botones = contenedor_botones.get_children()
	for btn in botones:
		btn.custom_minimum_size = Vector2(0, 45)
		aplicar_boton_callback.call(btn, Color(0.1, 0.1, 0.28), Color(0.3, 0.45, 0.8), 13)

func aplicar_color_pregunta_jugador(turno_actual: int):
	var color_fondo: Color
	var color_borde: Color
	
	if turno_actual == 1:
		color_fondo = Color(0.12, 0.04, 0.04, 0.97)
		color_borde = Color(0.7, 0.2, 0.2)
	else:
		color_fondo = Color(0.12, 0.1, 0.02, 0.97)
		color_borde = Color(0.7, 0.6, 0.1)
	
	if pantalla_pregunta is Panel:
		pantalla_pregunta.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(color_fondo, color_borde))

func limpiar_botones_extra():
	var btn_menu_extra = pantalla_pregunta.get_node_or_null("BtnMenuVictoria")
	if btn_menu_extra:
		btn_menu_extra.queue_free()
	
	var btn_continuar_extra = pantalla_pregunta.get_node_or_null("BotonContinuar")
	if btn_continuar_extra:
		btn_continuar_extra.queue_free()

func preparar_visual_pregunta():
	TemaPixel.aplicar_fuente_label(texto_pregunta, 16)
	texto_reloj.visible = false
	
	if barra_tiempo:
		barra_tiempo.size.x = barra_ancho_max
		barra_tiempo.color = Color(0.2, 0.8, 0.3)

func mostrar_esperando_host():
	texto_pregunta.text = "Sincronizando pregunta con el Host..."
	for boton in contenedor_botones.get_children():
		boton.hide()

func mostrar_sin_preguntas():
	texto_pregunta.text = "No hay preguntas disponibles."
	for boton in contenedor_botones.get_children():
		boton.hide()

func aplicar_pregunta_visual(turno_actual: int, mi_rol_multijugador: int, es_multijugador: bool, pregunta_actual: Dictionary, aplicar_boton_callback: Callable):
	var es_mi_turno = true
	if es_multijugador and turno_actual != mi_rol_multijugador:
		es_mi_turno = false

	var icono = "[P1]" if turno_actual == 1 else "[P2]"
	texto_pregunta.text = icono + " " + pregunta_actual["pregunta"]
	var botones = contenedor_botones.get_children()
	
	if es_mi_turno:
		aplicar_color_pregunta_jugador(turno_actual)
		texto_pregunta.add_theme_color_override("font_color", Color(0.9, 0.9, 1))
		for i in range(4):
			botones[i].disabled = false
			botones[i].text = pregunta_actual["opciones"][i]
			botones[i].show()
			aplicar_boton_callback.call(botones[i], Color(0.1, 0.1, 0.28), Color(0.3, 0.45, 0.8), 14)
	else:
		if pantalla_pregunta is Panel:
			pantalla_pregunta.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
				Color(0.1, 0.1, 0.1, 0.95), Color(0.3, 0.3, 0.3)
			))
		texto_pregunta.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		for i in range(4):
			botones[i].disabled = true
			botones[i].text = pregunta_actual["opciones"][i]
			botones[i].show()
			aplicar_boton_callback.call(botones[i], Color(0.15, 0.15, 0.15), Color(0.3, 0.3, 0.3), 14)
			botones[i].add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.4))
	
	if barra_tiempo:
		barra_tiempo.visible = true
	if barra_fondo:
		barra_fondo.visible = true

func mostrar_mensaje_error(
	respuesta_correcta: String,
	turno_actual: int,
	mi_rol_multijugador: int,
	es_multijugador: bool,
	callback_continuar: Callable,
	callback_hover: Callable,
	aplicar_boton_callback: Callable
):
	texto_pregunta.text = "[X] INCORRECTO!\n\nRespuesta correcta:\n" + respuesta_correcta
	if barra_tiempo:
		barra_tiempo.visible = false
	if barra_fondo:
		barra_fondo.visible = false
	
	for boton in contenedor_botones.get_children():
		boton.hide()
	
	var es_mi_turno = true
	if es_multijugador and turno_actual != mi_rol_multijugador:
		es_mi_turno = false

	var boton_continuar = Button.new()
	boton_continuar.name = "BotonContinuar"
	boton_continuar.text = "CONTINUAR >>"
	boton_continuar.position = Vector2(280, 320)
	boton_continuar.size = Vector2(240, 55)
	
	if es_mi_turno:
		aplicar_boton_callback.call(boton_continuar, Color(0.12, 0.12, 0.3), Color(0.3, 0.5, 0.9), 11)
		boton_continuar.pressed.connect(callback_continuar.bind(boton_continuar))
		boton_continuar.mouse_entered.connect(callback_hover)
	else:
		boton_continuar.disabled = true
		aplicar_boton_callback.call(boton_continuar, Color(0.15, 0.15, 0.15), Color(0.3, 0.3, 0.3), 11)
		boton_continuar.add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.4))

	pantalla_pregunta.add_child(boton_continuar)

func obtener_boton_continuar():
	return pantalla_pregunta.get_node_or_null("BotonContinuar")

func actualizar_reloj(time_left: float, tiempo_total: float, reproductor_tick: AudioStreamPlayer, snd_tick):
	var porcentaje = time_left / tiempo_total
	var tiempo_restante = int(ceil(time_left))
	
	if barra_tiempo:
		barra_tiempo.size.x = barra_ancho_max * porcentaje
		
		if porcentaje > 0.5:
			barra_tiempo.color = Color(0.2, 0.8, 0.3)
		elif porcentaje > 0.25:
			barra_tiempo.color = Color(1, 0.7, 0.1)
		else:
			barra_tiempo.color = Color(1, 0.2, 0.2)
	
	if tiempo_restante <= 6 and tiempo_restante != ultimo_segundo_reloj:
		if tiempo_restante == 6 and is_instance_valid(reproductor_tick):
			reproductor_tick.stream = snd_tick
			reproductor_tick.play()
		ultimo_segundo_reloj = tiempo_restante

func resetear_reloj():
	ultimo_segundo_reloj = -1

func crear_barra_tiempo():
	var panel_w = pantalla_pregunta.size.x
	var barra_w = panel_w - 80
	var barra_h = 14
	var barra_x = 40.0
	var barra_y = pantalla_pregunta.size.y / 2.0 - 110
	barra_ancho_max = barra_w
	
	barra_fondo = ColorRect.new()
	barra_fondo.name = "BarraFondo"
	barra_fondo.position = Vector2(barra_x, barra_y)
	barra_fondo.size = Vector2(barra_w, barra_h)
	barra_fondo.color = Color(0.1, 0.1, 0.15, 0.8)
	pantalla_pregunta.add_child(barra_fondo)
	
	barra_tiempo = ColorRect.new()
	barra_tiempo.name = "BarraTiempo"
	barra_tiempo.position = Vector2(barra_x, barra_y)
	barra_tiempo.size = Vector2(barra_w, barra_h)
	barra_tiempo.color = Color(0.2, 0.8, 0.3)
	barra_tiempo.z_index = 1
	pantalla_pregunta.add_child(barra_tiempo)
