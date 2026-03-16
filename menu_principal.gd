extends Control

func _ready():
	# Fondo
	var fondo = $FondoMenu
	fondo.color = Color(0.05, 0.05, 0.15)
	fondo.position = Vector2(0, 0)
	fondo.size = Vector2(1152, 648)
	
	# Título
	var titulo = $Titulo
	titulo.text = "🎮 LINE 4 UP"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(276, 80)
	titulo.size = Vector2(600, 100)
	titulo.add_theme_font_size_override("font_size", 64)
	titulo.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	
	# Subtítulo
	var subtitulo = $Subtitulo
	subtitulo.text = "🧠 Trivia Edition - ¡Responde para jugar!"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.position = Vector2(226, 190)
	subtitulo.size = Vector2(700, 50)
	subtitulo.add_theme_font_size_override("font_size", 22)
	subtitulo.add_theme_color_override("font_color", Color(0.7, 0.8, 1))
	
	# Botón Jugar
	var btn_jugar = $BotonJugar
	btn_jugar.text = "▶️ JUGAR"
	btn_jugar.position = Vector2(426, 300)
	btn_jugar.size = Vector2(300, 70)
	btn_jugar.add_theme_font_size_override("font_size", 32)
	
	var estilo_jugar = StyleBoxFlat.new()
	estilo_jugar.bg_color = Color(0.1, 0.5, 0.2)
	estilo_jugar.border_width_bottom = 3
	estilo_jugar.border_width_top = 3
	estilo_jugar.border_width_left = 3
	estilo_jugar.border_width_right = 3
	estilo_jugar.border_color = Color(0.3, 1, 0.4)
	estilo_jugar.corner_radius_top_left = 15
	estilo_jugar.corner_radius_top_right = 15
	estilo_jugar.corner_radius_bottom_left = 15
	estilo_jugar.corner_radius_bottom_right = 15
	btn_jugar.add_theme_stylebox_override("normal", estilo_jugar)
	btn_jugar.add_theme_color_override("font_color", Color(1, 1, 1))
	btn_jugar.pressed.connect(_on_jugar)
	
	# Botón Salir
	var btn_salir = $BotonSalir
	btn_salir.text = "🚪 SALIR"
	btn_salir.position = Vector2(476, 400)
	btn_salir.size = Vector2(200, 50)
	btn_salir.add_theme_font_size_override("font_size", 20)
	
	var estilo_salir = StyleBoxFlat.new()
	estilo_salir.bg_color = Color(0.5, 0.1, 0.1)
	estilo_salir.border_width_bottom = 2
	estilo_salir.border_width_top = 2
	estilo_salir.border_width_left = 2
	estilo_salir.border_width_right = 2
	estilo_salir.border_color = Color(1, 0.3, 0.3)
	estilo_salir.corner_radius_top_left = 10
	estilo_salir.corner_radius_top_right = 10
	estilo_salir.corner_radius_bottom_left = 10
	estilo_salir.corner_radius_bottom_right = 10
	btn_salir.add_theme_stylebox_override("normal", estilo_salir)
	btn_salir.add_theme_color_override("font_color", Color(1, 1, 1))
	btn_salir.pressed.connect(_on_salir)

func _on_jugar():
	get_tree().change_scene_to_file("res://juego_principal.tscn")

func _on_salir():
	get_tree().quit()
