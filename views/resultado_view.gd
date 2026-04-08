class_name ResultadoView
extends RefCounted

const TemaPixel = preload("res://efectos/tema_pixel.gd")

var pantalla_pregunta
var texto_pregunta
var texto_reloj
var contenedor_botones
var tablero_visual

func configurar(_pantalla_pregunta, _texto_pregunta, _texto_reloj, _contenedor_botones, _tablero_visual):
	pantalla_pregunta = _pantalla_pregunta
	texto_pregunta = _texto_pregunta
	texto_reloj = _texto_reloj
	contenedor_botones = _contenedor_botones
	tablero_visual = _tablero_visual

func crear_texto_resultado_superior(texto: String, color_texto: Color):
	var TextoScript = preload("res://efectos/texto_victoria.gd")
	var texto_nodo = Node2D.new()
	texto_nodo.set_script(TextoScript)
	texto_nodo.position = Vector2(576, 80)
	texto_nodo.texto = texto
	texto_nodo.color_texto = color_texto
	tablero_visual.add_child(texto_nodo)

func aplicar_estilo_victoria(turno_actual: int):
	var color_fondo: Color
	var color_borde: Color
	
	if turno_actual == 1:
		color_fondo = Color(0.12, 0.04, 0.04, 0.97)
		color_borde = Color(0.8, 0.25, 0.25)
	else:
		color_fondo = Color(0.12, 0.1, 0.02, 0.97)
		color_borde = Color(0.8, 0.65, 0.1)
	
	if pantalla_pregunta is Panel:
		pantalla_pregunta.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(color_fondo, color_borde))

func aplicar_estilo_empate():
	if pantalla_pregunta is Panel:
		pantalla_pregunta.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
			Color(0.08, 0.08, 0.14, 0.97), Color(0.5, 0.5, 0.6)
		))

func ocultar_botones_trivia():
	for boton in contenedor_botones.get_children():
		boton.hide()

func mostrar_panel_victoria(
	turno_actual: int,
	es_multijugador: bool,
	mi_rol_multijugador: int,
	callback_reiniciar: Callable,
	callback_menu: Callable,
	callback_hover: Callable,
	aplicar_boton_callback: Callable
):
	var soy_perdedor = (es_multijugador and turno_actual != mi_rol_multijugador)
	var color_nombre = Color(1, 0.3, 0.3) if turno_actual == 1 else Color(1, 0.85, 0.1)
	var ganador_nombre = "P" + str(turno_actual) + " " + ("ROJO" if turno_actual == 1 else "AMARILLO")
	
	if soy_perdedor:
		texto_pregunta.text = "DERROTA!"
		texto_pregunta.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		texto_reloj.text = ganador_nombre + "\nTE HA VENCIDO"
	else:
		texto_pregunta.text = "VICTORIA!"
		texto_pregunta.add_theme_color_override("font_color", color_nombre)
		texto_reloj.text = ganador_nombre + "\nGANA!"
	
	texto_pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TemaPixel.aplicar_fuente_label(texto_pregunta, 30)
	texto_reloj.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TemaPixel.aplicar_fuente_label(texto_reloj, 18)
	
	ocultar_botones_trivia()
	pantalla_pregunta.show()
	
	var pw = pantalla_pregunta.size.x
	var btn_ancho = 300
	var btn_x = (pw - btn_ancho) / 2.0
	
	var btn_jugar_nuevo = Button.new()
	btn_jugar_nuevo.name = "BtnJugarNuevoVic"
	btn_jugar_nuevo.text = "JUGAR DE NUEVO"
	btn_jugar_nuevo.position = Vector2(btn_x, pantalla_pregunta.size.y - 170)
	btn_jugar_nuevo.size = Vector2(btn_ancho, 55)
	aplicar_boton_callback.call(btn_jugar_nuevo, Color(0.06, 0.38, 0.12), Color(0.15, 0.85, 0.25), 12)
	btn_jugar_nuevo.pressed.connect(callback_reiniciar)
	btn_jugar_nuevo.mouse_entered.connect(callback_hover)
	pantalla_pregunta.add_child(btn_jugar_nuevo)
	
	var btn_ancho2 = 260
	var btn_x2 = (pw - btn_ancho2) / 2.0
	var btn_menu_vic = Button.new()
	btn_menu_vic.name = "BtnMenuVictoria"
	btn_menu_vic.text = "MENU PRINCIPAL"
	btn_menu_vic.position = Vector2(btn_x2, pantalla_pregunta.size.y - 100)
	btn_menu_vic.size = Vector2(btn_ancho2, 45)
	aplicar_boton_callback.call(btn_menu_vic, Color(0.3, 0.08, 0.08), Color(0.75, 0.25, 0.25), 11)
	btn_menu_vic.pressed.connect(callback_menu)
	btn_menu_vic.mouse_entered.connect(callback_hover)
	pantalla_pregunta.add_child(btn_menu_vic)

func mostrar_panel_empate(
	callback_reiniciar: Callable,
	callback_menu: Callable,
	callback_hover: Callable,
	aplicar_boton_callback: Callable
):
	texto_pregunta.text = "EMPATE!"
	texto_pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TemaPixel.aplicar_fuente_label(texto_pregunta, 30)
	texto_pregunta.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9))
	
	texto_reloj.text = "Nadie gano\nesta ronda"
	texto_reloj.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TemaPixel.aplicar_fuente_label(texto_reloj, 14)
	texto_reloj.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	
	ocultar_botones_trivia()
	pantalla_pregunta.show()
	
	var pw = pantalla_pregunta.size.x
	var btn_ancho = 300
	var btn_x = (pw - btn_ancho) / 2.0
	
	var btn_jugar_nuevo = Button.new()
	btn_jugar_nuevo.name = "BtnJugarNuevoVic"
	btn_jugar_nuevo.text = "JUGAR DE NUEVO"
	btn_jugar_nuevo.position = Vector2(btn_x, pantalla_pregunta.size.y - 170)
	btn_jugar_nuevo.size = Vector2(btn_ancho, 55)
	aplicar_boton_callback.call(btn_jugar_nuevo, Color(0.06, 0.38, 0.12), Color(0.15, 0.85, 0.25), 12)
	btn_jugar_nuevo.pressed.connect(callback_reiniciar)
	btn_jugar_nuevo.mouse_entered.connect(callback_hover)
	pantalla_pregunta.add_child(btn_jugar_nuevo)
	
	var btn_ancho2 = 260
	var btn_x2 = (pw - btn_ancho2) / 2.0
	var btn_menu_emp = Button.new()
	btn_menu_emp.name = "BtnMenuVictoria"
	btn_menu_emp.text = "MENU PRINCIPAL"
	btn_menu_emp.position = Vector2(btn_x2, pantalla_pregunta.size.y - 100)
	btn_menu_emp.size = Vector2(btn_ancho2, 45)
	aplicar_boton_callback.call(btn_menu_emp, Color(0.3, 0.08, 0.08), Color(0.75, 0.25, 0.25), 11)
	btn_menu_emp.pressed.connect(callback_menu)
	btn_menu_emp.mouse_entered.connect(callback_hover)
	pantalla_pregunta.add_child(btn_menu_emp)
