extends Control

var panel_instrucciones = null
var dificultad_seleccionada = "intermedio"

func _ready():
	var snd_hover = preload("res://sonidos/hover1.wav")
	var fondo = $FondoMenu
	fondo.color = Color(0.05, 0.05, 0.15)
	fondo.position = Vector2(0, 0)
	fondo.size = Vector2(1152, 648)
	
	var titulo = $Titulo
	titulo.text = "🎮 LINE 4 UP"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(276, 30)
	titulo.size = Vector2(600, 70)
	titulo.add_theme_font_size_override("font_size", 58)
	titulo.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	
	var subtitulo = $Subtitulo
	subtitulo.text = "🧠 Trivia Edition"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.position = Vector2(276, 100)
	subtitulo.size = Vector2(600, 35)
	subtitulo.add_theme_font_size_override("font_size", 22)
	subtitulo.add_theme_color_override("font_color", Color(0.7, 0.8, 1))
	
	# ====== SELECCIÓN DE DIFICULTAD ======
	var label_dificultad = Label.new()
	label_dificultad.text = "📚 Selecciona la dificultad:"
	label_dificultad.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_dificultad.position = Vector2(326, 155)
	label_dificultad.size = Vector2(500, 30)
	label_dificultad.add_theme_font_size_override("font_size", 18)
	label_dificultad.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	add_child(label_dificultad)
	
	# Contenedor de botones de dificultad
	var btn_basico = Button.new()
	btn_basico.name = "BtnBasico"
	btn_basico.text = "🟢 Básico"
	btn_basico.position = Vector2(296, 190)
	btn_basico.size = Vector2(170, 45)
	btn_basico.add_theme_font_size_override("font_size", 18)
	aplicar_estilo_boton(btn_basico, Color(0.1, 0.4, 0.15), Color(0.2, 0.7, 0.3))
	btn_basico.pressed.connect(_on_dificultad.bind("basico", btn_basico))
	agregar_hover_sonido(btn_basico)
	add_child(btn_basico)
	
	var btn_intermedio = Button.new()
	btn_intermedio.name = "BtnIntermedio"
	btn_intermedio.text = "🟡 Intermedio"
	btn_intermedio.position = Vector2(486, 190)
	btn_intermedio.size = Vector2(170, 45)
	btn_intermedio.add_theme_font_size_override("font_size", 18)
	aplicar_estilo_boton(btn_intermedio, Color(0.5, 0.4, 0.05), Color(1, 0.8, 0.2))
	btn_intermedio.pressed.connect(_on_dificultad.bind("intermedio", btn_intermedio))
	agregar_hover_sonido(btn_intermedio)
	add_child(btn_intermedio)
	
	var btn_avanzado = Button.new()
	btn_avanzado.name = "BtnAvanzado"
	btn_avanzado.text = "🔴 Avanzado"
	btn_avanzado.position = Vector2(676, 190)
	btn_avanzado.size = Vector2(170, 45)
	btn_avanzado.add_theme_font_size_override("font_size", 18)
	aplicar_estilo_boton(btn_avanzado, Color(0.5, 0.1, 0.1), Color(1, 0.3, 0.3))
	btn_avanzado.pressed.connect(_on_dificultad.bind("avanzado", btn_avanzado))
	agregar_hover_sonido(btn_avanzado)
	add_child(btn_avanzado)
	
	# Label que muestra la dificultad actual
	var label_seleccion = Label.new()
	label_seleccion.name = "LabelSeleccion"
	label_seleccion.text = "Seleccionado: 🟡 Intermedio"
	label_seleccion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_seleccion.position = Vector2(326, 245)
	label_seleccion.size = Vector2(500, 25)
	label_seleccion.add_theme_font_size_override("font_size", 16)
	label_seleccion.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	add_child(label_seleccion)
	
	# ====== BOTONES PRINCIPALES ======
	var btn_jugar = $BotonJugar
	btn_jugar.text = "▶️  JUGAR"
	btn_jugar.position = Vector2(426, 290)
	btn_jugar.size = Vector2(300, 65)
	btn_jugar.add_theme_font_size_override("font_size", 30)
	aplicar_estilo_boton(btn_jugar, Color(0.1, 0.5, 0.2), Color(0.3, 1, 0.4))
	btn_jugar.pressed.connect(_on_jugar)
	agregar_hover_sonido(btn_jugar)
	
	var btn_instrucciones = Button.new()
	btn_instrucciones.text = "📋  INSTRUCCIONES"
	btn_instrucciones.position = Vector2(426, 375)
	btn_instrucciones.size = Vector2(300, 50)
	btn_instrucciones.add_theme_font_size_override("font_size", 20)
	aplicar_estilo_boton(btn_instrucciones, Color(0.15, 0.2, 0.5), Color(0.3, 0.5, 1))
	btn_instrucciones.pressed.connect(_on_instrucciones)
	agregar_hover_sonido(btn_instrucciones)
	add_child(btn_instrucciones)
	
	# Botón Salir
	var btn_salir = $BotonSalir
	btn_salir.text = "🚪  SALIR"
	btn_salir.position = Vector2(476, 520)
	btn_salir.size = Vector2(200, 45)
	btn_salir.add_theme_font_size_override("font_size", 18)
	aplicar_estilo_boton(btn_salir, Color(0.5, 0.1, 0.1), Color(1, 0.3, 0.3))
	btn_salir.pressed.connect(_on_salir)
	agregar_hover_sonido(btn_salir)
	
	crear_panel_instrucciones()

func aplicar_estilo_boton(boton, color_fondo, color_borde):
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = color_fondo
	estilo.border_width_bottom = 3
	estilo.border_width_top = 3
	estilo.border_width_left = 3
	estilo.border_width_right = 3
	estilo.border_color = color_borde
	estilo.corner_radius_top_left = 12
	estilo.corner_radius_top_right = 12
	estilo.corner_radius_bottom_left = 12
	estilo.corner_radius_bottom_right = 12
	boton.add_theme_stylebox_override("normal", estilo)
	
	var estilo_hover = estilo.duplicate()
	estilo_hover.bg_color = Color(color_fondo.r + 0.1, color_fondo.g + 0.1, color_fondo.b + 0.1)
	boton.add_theme_stylebox_override("hover", estilo_hover)
	
	boton.add_theme_color_override("font_color", Color(1, 1, 1))
	boton.add_theme_color_override("font_hover_color", Color(1, 1, 0.8))

# ====== DIFICULTAD ======
func _on_dificultad(nivel, boton):
	dificultad_seleccionada = nivel
	
	var textos = {
		"basico": "Seleccionado: 🟢 Básico",
		"intermedio": "Seleccionado: 🟡 Intermedio",
		"avanzado": "Seleccionado: 🔴 Avanzado"
	}
	
	var colores = {
		"basico": Color(0.2, 0.8, 0.3),
		"intermedio": Color(1, 0.8, 0.2),
		"avanzado": Color(1, 0.3, 0.3)
	}
	
	var label = get_node("LabelSeleccion")
	label.text = textos[nivel]
	label.add_theme_color_override("font_color", colores[nivel])

# ====== INSTRUCCIONES ======
func crear_panel_instrucciones():
	panel_instrucciones = Control.new()
	panel_instrucciones.name = "PanelInstrucciones"
	panel_instrucciones.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_instrucciones.hide()
	add_child(panel_instrucciones)
	
	var fondo_oscuro = ColorRect.new()
	fondo_oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo_oscuro.color = Color(0, 0, 0, 0.7)
	panel_instrucciones.add_child(fondo_oscuro)
	
	var ventana = Panel.new()
	ventana.position = Vector2(76, 24)
	ventana.size = Vector2(1000, 600)
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.08, 0.2, 0.98)
	estilo.border_width_bottom = 3
	estilo.border_width_top = 3
	estilo.border_width_left = 3
	estilo.border_width_right = 3
	estilo.border_color = Color(0.3, 0.5, 1)
	estilo.corner_radius_top_left = 15
	estilo.corner_radius_top_right = 15
	estilo.corner_radius_bottom_left = 15
	estilo.corner_radius_bottom_right = 15
	ventana.add_theme_stylebox_override("panel", estilo)
	panel_instrucciones.add_child(ventana)
	
	var titulo_inst = Label.new()
	titulo_inst.text = "📋  INSTRUCCIONES"
	titulo_inst.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo_inst.position = Vector2(250, 12)
	titulo_inst.size = Vector2(500, 40)
	titulo_inst.add_theme_font_size_override("font_size", 28)
	titulo_inst.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	ventana.add_child(titulo_inst)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(20, 60)
	scroll.size = Vector2(960, 470)
	ventana.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	
	agregar_seccion(vbox, "🎯  OBJETIVO:", [
		"Conecta 4 fichas en línea (horizontal, vertical o diagonal) para ganar."
	])
	agregar_seccion(vbox, "⏰  MECÁNICA:", [
		"• Cada turno debes responder una pregunta de inglés",
		"• Si aciertas, puedes lanzar una ficha en el tablero",
		"• Si fallas, pierdes tu turno",
		"• Tienes 15 segundos para responder"
	])
	agregar_seccion(vbox, "⚡  PODERES ESPECIALES:", [
		"Se ganan al responder 2 preguntas correctas seguidas (racha).",
		"El poder ganado es aleatorio entre:"
	])
	agregar_seccion(vbox, "      💣  BOMBA:", [
		"            Selecciona y destruye una ficha del oponente.",
		"            Las fichas de arriba caerán para llenar el espacio.",
		"            No funciona en columnas congeladas."
	])
	agregar_seccion(vbox, "      ❄️  HIELO:", [
		"            Congela una columna completa.",
		"            Nadie puede lanzar fichas ni destruir fichas ahí.",
		"            Se descongela cuando vuelve a ser tu turno.",
		"            Después de congelar, aún puedes lanzar tu ficha normal."
	])
	agregar_seccion(vbox, "🎹  CONTROLES:", [
		"      [1]  Seleccionar ficha normal",
		"      [2]  Seleccionar bomba",
		"      [3]  Seleccionar hielo",
		"      [Esc]  Cancelar selección de poder"
	])
	
	var btn_cerrar = Button.new()
	btn_cerrar.text = "✖  CERRAR"
	btn_cerrar.position = Vector2(425, 542)
	btn_cerrar.size = Vector2(150, 45)
	btn_cerrar.add_theme_font_size_override("font_size", 18)
	aplicar_estilo_boton(btn_cerrar, Color(0.5, 0.1, 0.1), Color(1, 0.3, 0.3))
	btn_cerrar.pressed.connect(_on_cerrar_instrucciones)
	agregar_hover_sonido(btn_cerrar)
	ventana.add_child(btn_cerrar)

func agregar_seccion(contenedor, titulo, lineas):
	var separador = Control.new()
	separador.custom_minimum_size = Vector2(0, 8)
	contenedor.add_child(separador)
	
	var label_titulo = Label.new()
	label_titulo.text = titulo
	label_titulo.add_theme_font_size_override("font_size", 17)
	label_titulo.add_theme_color_override("font_color", Color(0.4, 0.7, 1))
	contenedor.add_child(label_titulo)
	
	for linea in lineas:
		var label_linea = Label.new()
		label_linea.text = linea
		label_linea.add_theme_font_size_override("font_size", 15)
		label_linea.add_theme_color_override("font_color", Color(0.82, 0.82, 0.92))
		label_linea.autowrap_mode = TextServer.AUTOWRAP_WORD
		contenedor.add_child(label_linea)

# ====== NAVEGACIÓN ======
func _on_jugar():
	# Guardar la dificultad seleccionada en un Autoload global
	Global.dificultad = dificultad_seleccionada
	get_tree().change_scene_to_file("res://juego_principal.tscn")

func _on_instrucciones():
	panel_instrucciones.show()

func _on_cerrar_instrucciones():
	panel_instrucciones.hide()

func _on_salir():
	get_tree().quit()

func agregar_hover_sonido(boton):
	boton.mouse_entered.connect(_on_hover_boton)

func _on_hover_boton():
	$SonidoHover.stream = preload("res://sonidos/hover1.wav")
	$SonidoHover.play()
