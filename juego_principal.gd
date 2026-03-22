extends Node2D

# ====== CLASE PARA ICONO FULLSCREEN DINÁMICO ======
class IconoFullscreen extends Control:
	var is_fullscreen = false
	
	func actualizar_estado(estado):
		is_fullscreen = estado
		queue_redraw()

	func _draw():
		var c = Color(1, 1, 1, 0.9)
		if not is_fullscreen:
			# Expandir (Esquinas apuntando hacia AFUERA ⌜ ⌝ ⌞ ⌟)
			draw_rect(Rect2(12, 12, 9, 3), c)
			draw_rect(Rect2(12, 12, 3, 9), c)
			draw_rect(Rect2(24, 12, 9, 3), c)
			draw_rect(Rect2(30, 12, 3, 9), c)
			draw_rect(Rect2(12, 30, 9, 3), c)
			draw_rect(Rect2(12, 24, 3, 9), c)
			draw_rect(Rect2(24, 30, 9, 3), c)
			draw_rect(Rect2(30, 24, 3, 9), c)
		else:
			# Contraer (Esquinas apuntando hacia ADENTRO ⌟ ⌞ ⌝ ⌜)
			draw_rect(Rect2(13, 19, 9, 3), c)
			draw_rect(Rect2(19, 13, 3, 9), c)
			draw_rect(Rect2(23, 19, 9, 3), c)
			draw_rect(Rect2(23, 13, 3, 9), c)
			draw_rect(Rect2(13, 23, 9, 3), c)
			draw_rect(Rect2(19, 23, 3, 9), c)
			draw_rect(Rect2(23, 23, 9, 3), c)
			draw_rect(Rect2(23, 23, 3, 9), c)

# ====== CLASE PARA CELDAS REDONDAS ======
class CeldaRedonda extends Control:
	var color_celda = Color(0, 0, 0, 0) # TOTALMENTE TRANSPARENTE
	var color_tablero = Color(0.08, 0.15, 0.4) 
	
	func set_color(nuevo_color):
		color_celda = nuevo_color
		queue_redraw()
	
	func _draw():
		var w = size.x
		var h = size.y
		var radio = w / 2.0
		var centro = Vector2(radio, radio)
		var radio_agujero = radio - 6.0 # El tamaño del agujero
		
		# --- MAGIA: Dibujar un cuadrado con un agujero transparente ---
		var puntos = PackedVector2Array()
		# Borde exterior
		puntos.push_back(Vector2(0, 0))
		puntos.push_back(Vector2(w, 0))
		puntos.push_back(Vector2(w, h))
		puntos.push_back(Vector2(0, h))
		puntos.push_back(Vector2(0, 0))
		# Costura hacia adentro
		puntos.push_back(Vector2(radio, radio - radio_agujero))
		# Círculo interior (en sentido contrario para crear el hueco)
		for i in range(32, -1, -1):
			var angle = (i / 32.0) * TAU - (PI / 2.0)
			puntos.push_back(centro + Vector2(cos(angle), sin(angle)) * radio_agujero)
		# Cerrar costura
		puntos.push_back(Vector2(0, 0))
		
		# Dibujar el "plástico" del tablero
		draw_colored_polygon(puntos, color_tablero)
		
		# Sombra y luz en el borde del agujero para que parezca 3D
		draw_arc(centro, radio_agujero, 0, TAU, 32, Color(0.02, 0.05, 0.1), 3.0, true)
		draw_arc(centro, radio_agujero + 2, 0, TAU, 32, Color(0.2, 0.4, 0.8), 1.0, true)
		
		# Tornillos decorativos
		var c_tornillo = Color(0.02, 0.04, 0.1)
		draw_rect(Rect2(4, 4, 3, 3), c_tornillo)
		draw_rect(Rect2(w - 7, 4, 3, 3), c_tornillo)
		draw_rect(Rect2(4, h - 7, 3, 3), c_tornillo)
		draw_rect(Rect2(w - 7, h - 7, 3, 3), c_tornillo)

		# Si hay un color (como el hielo), se dibuja translúcido sobre el hueco
		if color_celda.a > 0:
			draw_circle(centro, radio_agujero, color_celda)

const TemaPixel = preload("res://efectos/tema_pixel.gd")
const IconoPixel = preload("res://efectos/icono_pixel.gd")
var panel_pausa = null
var juego_pausado = false

# ====== PREVIEW DE FICHA ======
var preview_ficha = null
var preview_columna_actual = -1
var cursor_poder_label = null
var _cursor_tipo_actual = ""

# ====== REFERENCIAS A LOS NODOS ======
@onready var pantalla_pregunta = $CapaUI/PantallaPregunta
@onready var texto_pregunta = $CapaUI/PantallaPregunta/TextoPregunta
@onready var contenedor_botones = $CapaUI/PantallaPregunta/ContenedorBotones
@onready var texto_reloj = $CapaUI/PantallaPregunta/TextoReloj
@onready var temporizador = $Temporizador
@onready var tablero_visual = $TableroVisual
@onready var capa_ui = $CapaUI

var fichas_ganadoras = []  # Guardará las posiciones de las 4 fichas que ganaron


var ficha_escena = preload("res://ficha.tscn")
# ====== SONIDOS ======
@onready var sonido_ficha = $SonidoFicha
@onready var sonido_efectos = $SonidoEfectos
@onready var sonido_ui = $SonidoUI

# Sonidos de fichas cayendo (uno por cada fila)
var sonidos_ficha = {
	5: preload("res://sonidos/fichaf1.wav"),  # Fila del fondo (índice 5)
	4: preload("res://sonidos/fichaf2.wav"),
	3: preload("res://sonidos/fichaf3.wav"),
	2: preload("res://sonidos/fichaf4.wav"),
	1: preload("res://sonidos/fichaf5.wav"),
	0: preload("res://sonidos/fichaf6.wav")   # Fila de arriba (índice 0)
}

# Sonidos de efectos especiales
var snd_bomba_seleccionada = preload("res://sonidos/bomba_seleccionada.wav")
var snd_hielo_seleccionado = preload("res://sonidos/hielo_seleccionado.wav")
var snd_congelado = preload("res://sonidos/congelado.wav")
var snd_explosion = preload("res://sonidos/explosion.wav")
var snd_retirar_fichas = preload("res://sonidos/retirar_todas_fichas.wav")
var snd_ficha_seleccionada = preload("res://sonidos/ficha_seleccionada.wav")
var snd_victoria = preload("res://sonidos/clapping.wav")
var snd_empate = preload("res://sonidos/draw.wav")
var snd_tick = preload("res://sonidos/tick.wav")
var ultimo_segundo_reloj = -1
var reproductor_tick = AudioStreamPlayer.new() # REPRODUCTOR GLOBAL

# Sonidos de trivia
var snd_correcto = preload("res://sonidos/correcto.wav")
var snd_incorrecto = preload("res://sonidos/incorrecto.wav")


# ====== CONFIGURACIÓN DEL TABLERO ======
const COLUMNAS = 7
const FILAS = 6
const TAMANO_CELDA = 70
const ESPACIO = 5

var tablero_x = 311
var tablero_y = 145

var color_fondo_tablero = Color(0.08, 0.15, 0.4)
var color_celda_vacia = Color(0, 0, 0, 0) # TRANSPARENTE
var color_celda_congelada = Color(0.2, 0.6, 0.9, 0.5) # Translúcido
var color_fondo_pantalla = Color(0.05, 0.05, 0.08)
var color_seleccionable = Color(1.0, 0.3, 0.3, 0.4)

var matriz_tablero = []
var fichas_visuales = []

# ====== VARIABLES DEL JUEGO ======
var turno_actual = 1
var pregunta_actual = {}
var fase_juego = "PREGUNTA"  # PREGUNTA, LANZAMIENTO, BOMBA_SELECCION, ANIMANDO, FIN
var juego_terminado = false

var racha_j1 = 0
var racha_j2 = 0

# ====== FICHAS ESPECIALES ======
var bombas_j1 = 0
var bombas_j2 = 0
var hielos_j1 = 0
var hielos_j2 = 0

var poder_seleccionado = "NINGUNO"
var columnas_congeladas_info = []

# Resaltado de fichas destruibles
var fichas_resaltadas = []

# Referencias UI
var panel_poderes = null
var label_inventario_j1 = null
var label_inventario_j2 = null
var boton_bomba = null
var boton_hielo = null
var boton_normal = null
var boton_cancelar = null
var label_poder_activo = null
var label_turno = null
var label_notificacion = null
var boton_reiniciar = null

# ====== BASE DE DATOS DE PREGUNTAS ======
var preguntas_base = []

var preguntas_activas = []

# ====== FUNCIONES DE POSICIÓN ======
func celda_pos_x(columna):
	return tablero_x + ESPACIO + columna * (TAMANO_CELDA + ESPACIO)

func celda_pos_y(fila):
	return tablero_y + ESPACIO + fila * (TAMANO_CELDA + ESPACIO)

# ====== FUNCIONES DE SONIDO ======
func reproducir_ficha(fila):
	if sonidos_ficha.has(fila):
		sonido_ficha.stream = sonidos_ficha[fila]
		sonido_ficha.play()

func reproducir_efecto(sonido):
	sonido_efectos.stream = sonido
	sonido_efectos.play()

func reproducir_ui(sonido):
	sonido_ui.stream = sonido
	sonido_ui.play()

# ====== INICIO ======
func _ready():
	cargar_preguntas()
	preguntas_activas = preguntas_base.duplicate(true)
	crear_matriz_tablero()
	crear_matriz_fichas_visuales()
	dibujar_tablero()
	crear_interfaz_poderes()
	crear_notificacion()
	conectar_botones_trivia()
	estilizar_pantalla_pregunta()
	
	if not temporizador.timeout.is_connected(_on_tiempo_agotado):
		temporizador.timeout.connect(_on_tiempo_agotado)
	crear_menu_pausa()
	# Reproducir música del juego
	$MusicaJuego.stream = preload("res://musica/game_theme.wav")
	$MusicaJuego.volume_db = -12
	$MusicaJuego.play()
	$MusicaJuego.finished.connect(_on_musica_terminada)
	# Botón de música
	var btn_musica = Global.crear_boton_musica(capa_ui, _on_toggle_musica_juego)
	btn_musica.position = Vector2(60, 10)  # Al lado del botón de pausa
	
	# --- BOTÓN PANTALLA COMPLETA ---
	var btn_fs = Button.new()
	btn_fs.name = "BotonFullscreen"
	btn_fs.position = Vector2(110, 10) # Al lado del botón de música
	btn_fs.size = Vector2(45, 45)
	btn_fs.z_index = 50
	
	# Le aplicamos el mismo estilo pixel retro oscuro
	var estilos_fs = TemaPixel.crear_boton_pixel(Color(0.12, 0.12, 0.25, 0.85), Color(0.35, 0.4, 0.7))
	btn_fs.add_theme_stylebox_override("normal", estilos_fs["normal"])
	btn_fs.add_theme_stylebox_override("hover", estilos_fs["hover"])
	btn_fs.add_theme_stylebox_override("pressed", estilos_fs["pressed"])
	
	btn_fs.pressed.connect(_on_toggle_fullscreen)
	agregar_hover_sonido_juego(btn_fs)
	
	# Agregamos el icono dibujado
	var icono_fs = IconoFullscreen.new()
	icono_fs.name = "IconoFS"
	icono_fs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_fs.add_child(icono_fs)
	add_child(btn_fs)
	
	# Sincronizar el dibujo del icono con el estado actual de la ventana al abrir el juego
	var modo_actual = DisplayServer.window_get_mode()
	icono_fs.actualizar_estado(modo_actual == DisplayServer.WINDOW_MODE_FULLSCREEN or modo_actual == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	# Música del juego
	$MusicaJuego.stream = preload("res://musica/game_theme.wav")
	$MusicaJuego.volume_db = -12
	if Global.musica_activa:
		$MusicaJuego.play()
	$MusicaJuego.finished.connect(_on_musica_terminada)
	add_child(reproductor_tick)
	iniciar_turno()

func _on_toggle_musica_juego():
	Global.musica_activa = !Global.musica_activa
	var btn = capa_ui.get_node_or_null("BotonMusica")
	Global.actualizar_boton_musica(btn)
	
	if Global.musica_activa:
		if not $MusicaJuego.playing:
			$MusicaJuego.play()
	else:
		$MusicaJuego.stop()

func _on_musica_terminada():
	$MusicaJuego.play()

func cargar_preguntas():
	var archivo = FileAccess.open("res://datos/preguntas.json", FileAccess.READ)
	if archivo == null:
		print("ERROR: No se pudo abrir preguntas.json")
		preguntas_base = [
			{"pregunta": "Pregunta de emergencia: ¿Capital de Colombia?", "opciones": ["Medellín", "Bogotá", "Cali", "Cartagena"], "correcta": 1}
		]
		return
	var contenido = archivo.get_as_text()
	archivo.close()
	
	var json = JSON.new()
	var resultado = json.parse(contenido)
	
	if resultado != OK:
		print("ERROR: JSON mal formateado")
		return
	
	var datos = json.data
	var categoria = Global.categoria
	
	if datos.has(categoria):
		preguntas_base = datos[categoria]
		print("Cargadas ", preguntas_base.size(), " preguntas - Categoría: ", categoria)
	else:
		print("ERROR: Categoría '", categoria, "' no encontrada en JSON")


func crear_matriz_tablero():
	matriz_tablero = []
	for x in range(COLUMNAS):
		var columna = []
		for y in range(FILAS):
			columna.append(0)
		matriz_tablero.append(columna)

func crear_matriz_fichas_visuales():
	fichas_visuales = []
	for x in range(COLUMNAS):
		var columna = []
		for y in range(FILAS):
			columna.append(null)
		fichas_visuales.append(columna)

# ====== DIBUJAR TABLERO ======
# ====== DIBUJAR TABLERO ======
func dibujar_tablero():
	# 1. Fondo base de la pantalla
	var fondo_pantalla = ColorRect.new()
	fondo_pantalla.name = "FondoPantalla"
	fondo_pantalla.size = Vector2(1152, 648)
	fondo_pantalla.color = color_fondo_pantalla
	fondo_pantalla.z_index = -20
	tablero_visual.add_child(fondo_pantalla)
	
	# 2. Fondo animado del juego (Naves y estrellas)
	var FondoJuegoScript = preload("res://efectos/fondo_juego.gd")
	var fondo_juego = Node2D.new()
	fondo_juego.set_script(FondoJuegoScript)
	fondo_juego.z_index = -15
	tablero_visual.add_child(fondo_juego)
	
	var ancho_tablero = COLUMNAS * (TAMANO_CELDA + ESPACIO) + ESPACIO
	var alto_tablero = FILAS * (TAMANO_CELDA + ESPACIO) + ESPACIO
	
	# 3. NUEVO: Cristal oscuro trasero (para que se distingan las fichas)
	var cristal_trasero = ColorRect.new()
	cristal_trasero.size = Vector2(ancho_tablero, alto_tablero)
	cristal_trasero.position = Vector2(tablero_x, tablero_y)
	cristal_trasero.color = Color(0.0, 0.02, 0.08, 0.65) # Semitransparente oscuro
	cristal_trasero.z_index = 0 # Detrás de las fichas
	tablero_visual.add_child(cristal_trasero)
	
	# 4. Marco de Neón (Totalmente transparente en el centro)
	var fondo_tablero = Panel.new()
	fondo_tablero.name = "FondoTablero"
	fondo_tablero.size = Vector2(ancho_tablero + 16, alto_tablero + 16)
	fondo_tablero.position = Vector2(tablero_x - 8, tablero_y - 8)
	fondo_tablero.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0, 0, 0, 0), # <- Alpha cero para no tapar nada
		Color(0.2, 0.8, 1.0)
	))
	fondo_tablero.z_index = 10 # Se dibuja ADELANTE de todo
	tablero_visual.add_child(fondo_tablero)
	
	# 5. Celdas con agujeros
	for x in range(COLUMNAS):
		for y in range(FILAS):
			var celda = CeldaRedonda.new()
			celda.name = "Celda_" + str(x) + "_" + str(y)
			celda.size = Vector2(TAMANO_CELDA, TAMANO_CELDA)
			celda.position = Vector2(celda_pos_x(x), celda_pos_y(y))
			celda.color_celda = color_celda_vacia
			celda.color_tablero = color_fondo_tablero
			celda.z_index = 10 # Manda las celdas al FRENTE
			tablero_visual.add_child(celda)
	
	# Flechas e Inventarios (Resto queda igual)
	for x in range(COLUMNAS):
		var flecha = Label.new()
		flecha.name = "Flecha_" + str(x)
		flecha.text = "▼"
		flecha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		flecha.position = Vector2(celda_pos_x(x) + 22, tablero_y - 30)
		TemaPixel.aplicar_fuente_label(flecha, 14)
		flecha.add_theme_color_override("font_color", Color(0.3, 0.9, 0.8, 0.8))
		tablero_visual.add_child(flecha)
	
	label_inventario_j1 = Label.new()
	label_inventario_j1.position = Vector2(15, 160)
	label_inventario_j1.size = Vector2(280, 80)
	TemaPixel.aplicar_fuente_label(label_inventario_j1, 9)
	label_inventario_j1.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	tablero_visual.add_child(label_inventario_j1)
	
	label_inventario_j2 = Label.new()
	label_inventario_j2.position = Vector2(15, 280)
	label_inventario_j2.size = Vector2(280, 80)
	TemaPixel.aplicar_fuente_label(label_inventario_j2, 9)
	label_inventario_j2.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	tablero_visual.add_child(label_inventario_j2)
	
	label_turno = Label.new()
	label_turno.name = "EtiquetaTurno"
	label_turno.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_turno.position = Vector2(tablero_x, tablero_y + alto_tablero + 15)
	label_turno.size = Vector2(ancho_tablero, 30)
	TemaPixel.aplicar_fuente_label(label_turno, 11)
	label_turno.add_theme_color_override("font_color", Color(1, 1, 1))
	tablero_visual.add_child(label_turno)

func _dibujar_celda(celda):
	var radio = celda.size.x / 2.0
	var centro = Vector2(radio, radio)
	var color = celda.get_meta("color_actual")
	
	# Antialiasing manual: dibujar un círculo ligeramente más grande con color del tablero
	draw_circle(centro, radio + 1, color_fondo_tablero)
	# Círculo principal con más definición
	draw_circle(centro, radio, color)

# ====== NOTIFICACIÓN DE PODER ======
func crear_notificacion():
	label_notificacion = Label.new()
	label_notificacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_notificacion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_notificacion.position = Vector2(226, 65)
	label_notificacion.size = Vector2(700, 45)
	TemaPixel.aplicar_fuente_label(label_notificacion, 13)
	label_notificacion.add_theme_color_override("font_color", Color(1, 1, 0.3))
	label_notificacion.modulate.a = 0
	label_notificacion.z_index = 30
	capa_ui.add_child(label_notificacion)

func mostrar_notificacion(texto):
	label_notificacion.text = texto
	# Cancelar cualquier tween anterior
	var tweens_previos = label_notificacion.get_meta("tween", null)
	if tweens_previos and tweens_previos.is_valid():
		tweens_previos.kill()
	
	var tween = create_tween()
	label_notificacion.set_meta("tween", tween)
	tween.tween_property(label_notificacion, "modulate:a", 1.0, 0.2)
	tween.tween_interval(2.0)
	tween.tween_property(label_notificacion, "modulate:a", 0.0, 0.4)

func estilizar_pantalla_pregunta():
	TemaPixel.aplicar_fuente_label(texto_pregunta, 15)
	texto_pregunta.add_theme_color_override("font_color", Color(0.9, 0.9, 1))
	TemaPixel.aplicar_fuente_label(texto_reloj, 23)
	texto_reloj.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	
	var botones = contenedor_botones.get_children()
	for btn in botones:
		btn.custom_minimum_size = Vector2(0, 45)
		aplicar_boton_pixel_juego(btn, Color(0.1, 0.1, 0.28), Color(0.3, 0.45, 0.8), 13)

func aplicar_color_pregunta_jugador():
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

# ====== INTERFAZ DE PODERES ======
func crear_interfaz_poderes():
	panel_poderes = Panel.new()
	panel_poderes.position = Vector2(220, 5)
	panel_poderes.size = Vector2(720, 50)
	panel_poderes.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.1, 0.1, 0.2, 0.95),
		Color(0.3, 0.4, 0.7)
	))
	capa_ui.add_child(panel_poderes)
	
	var boton_ancho = 140
	var boton_alto = 34
	var margen_y = 8
	var inicio_x = 8
	var separacion = 8
	
	boton_normal = Button.new()
	boton_normal.text = "[1] NORMAL"
	boton_normal.position = Vector2(inicio_x, margen_y)
	boton_normal.size = Vector2(boton_ancho, boton_alto)
	aplicar_boton_pixel_juego(boton_normal, Color(0.1, 0.3, 0.15), Color(0.2, 0.7, 0.3), 9)
	boton_normal.pressed.connect(_on_seleccionar_normal)
	agregar_hover_sonido_juego(boton_normal)
	panel_poderes.add_child(boton_normal)
	
	boton_bomba = Button.new()
	boton_bomba.text = "[2] BOMBA"
	boton_bomba.position = Vector2(inicio_x + (boton_ancho + separacion), margen_y)
	boton_bomba.size = Vector2(boton_ancho, boton_alto)
	aplicar_boton_pixel_juego(boton_bomba, Color(0.35, 0.15, 0.05), Color(0.9, 0.4, 0.1), 9)
	boton_bomba.pressed.connect(_on_seleccionar_bomba)
	agregar_hover_sonido_juego(boton_bomba)
	panel_poderes.add_child(boton_bomba)
	
	boton_hielo = Button.new()
	boton_hielo.text = "[3] HIELO"
	boton_hielo.position = Vector2(inicio_x + (boton_ancho + separacion) * 2, margen_y)
	boton_hielo.size = Vector2(boton_ancho, boton_alto)
	aplicar_boton_pixel_juego(boton_hielo, Color(0.1, 0.2, 0.4), Color(0.3, 0.7, 1), 9)
	boton_hielo.pressed.connect(_on_seleccionar_hielo)
	agregar_hover_sonido_juego(boton_hielo)
	panel_poderes.add_child(boton_hielo)
	
	boton_cancelar = Button.new()
	boton_cancelar.text = "[ESC]"
	boton_cancelar.position = Vector2(inicio_x + (boton_ancho + separacion) * 3, margen_y)
	boton_cancelar.size = Vector2(90, boton_alto)
	aplicar_boton_pixel_juego(boton_cancelar, Color(0.3, 0.1, 0.1), Color(0.8, 0.3, 0.3), 9)
	boton_cancelar.pressed.connect(_on_cancelar_poder)
	agregar_hover_sonido_juego(boton_cancelar)
	boton_cancelar.hide()
	panel_poderes.add_child(boton_cancelar)
	
	label_poder_activo = Label.new()
	label_poder_activo.position = Vector2(inicio_x + (boton_ancho + separacion) * 3 + 100, margen_y + 5)
	label_poder_activo.size = Vector2(200, 30)
	TemaPixel.aplicar_fuente_label(label_poder_activo, 10)
	label_poder_activo.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	panel_poderes.add_child(label_poder_activo)
	
	# Botón de reiniciar
	boton_reiniciar = Button.new()
	boton_reiniciar.text = "JUGAR DE NUEVO"
	boton_reiniciar.position = Vector2(426, 550)
	boton_reiniciar.size = Vector2(300, 55)
	aplicar_boton_pixel_juego(boton_reiniciar, Color(0.08, 0.45, 0.15), Color(0.2, 1, 0.35), 14)
	boton_reiniciar.pressed.connect(_on_reiniciar)
	agregar_hover_sonido_juego(boton_reiniciar)
	boton_reiniciar.hide()
	capa_ui.add_child(boton_reiniciar)
	
	panel_poderes.hide()
	actualizar_inventario()

func aplicar_boton_pixel_juego(boton, color_fondo, color_borde, tam: int = 11):
	var estilos = TemaPixel.crear_boton_pixel(color_fondo, color_borde)
	boton.add_theme_stylebox_override("normal", estilos["normal"])
	boton.add_theme_stylebox_override("hover", estilos["hover"])
	boton.add_theme_stylebox_override("pressed", estilos["pressed"])
	boton.add_theme_color_override("font_color", Color(1, 1, 1))
	boton.add_theme_color_override("font_hover_color", Color(1, 1, 0.7))
	TemaPixel.aplicar_fuente_boton(boton, tam)

func actualizar_inventario():
	label_inventario_j1.text = "P1 ROJO\nBOMBAS: " + str(bombas_j1) + "\nHIELOS: " + str(hielos_j1)
	label_inventario_j2.text = "P2 AMARILLO\nBOMBAS: " + str(bombas_j2) + "\nHIELOS: " + str(hielos_j2)

func mostrar_botones_poder():
	panel_poderes.show()
	boton_cancelar.hide()
	label_poder_activo.show()
	
	if turno_actual == 1:
		boton_bomba.disabled = bombas_j1 <= 0
		boton_hielo.disabled = hielos_j1 <= 0
	else:
		boton_bomba.disabled = bombas_j2 <= 0
		boton_hielo.disabled = hielos_j2 <= 0
	
	poder_seleccionado = "NINGUNO"
	label_poder_activo.text = "Modo: NORMAL"
	label_poder_activo.add_theme_color_override("font_color", Color(0.5, 1, 0.5))

func ocultar_botones_poder():
	panel_poderes.hide()
	limpiar_resaltado()

func _on_seleccionar_normal():
	poder_seleccionado = "NINGUNO"
	label_poder_activo.text = "Modo: NORMAL"
	label_poder_activo.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	boton_cancelar.hide()
	label_poder_activo.show()
	limpiar_resaltado()
	reproducir_ui(snd_ficha_seleccionada)

func _on_seleccionar_bomba():
	poder_seleccionado = "BOMBA"
	label_poder_activo.text = "Poder: BOMBA"
	label_poder_activo.add_theme_color_override("font_color", Color(1, 0.5, 0.2))
	boton_cancelar.show()
	label_poder_activo.show()
	resaltar_fichas_enemigas()
	reproducir_ui(snd_bomba_seleccionada)

func _on_seleccionar_hielo():
	poder_seleccionado = "HIELO"
	label_poder_activo.text = "Poder: ❄️ HIELO"
	label_poder_activo.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
	boton_cancelar.show()
	label_poder_activo.show()  # Ahora se muestra junto con Cancelar
	limpiar_resaltado()
	reproducir_ui(snd_hielo_seleccionado)

func _on_cancelar_poder():
	_on_seleccionar_normal()

# ====== RESALTAR FICHAS ENEMIGAS (para bomba) ======
func resaltar_fichas_enemigas():
	limpiar_resaltado()
	var enemigo = 2 if turno_actual == 1 else 1
	
	for x in range(COLUMNAS):
		# No resaltar fichas en columnas congeladas
		if esta_columna_congelada(x):
			continue
		
		for y in range(FILAS):
			if matriz_tablero[x][y] == enemigo:
				var resaltado = ColorRect.new()
				resaltado.name = "Resaltado_" + str(x) + "_" + str(y)
				resaltado.size = Vector2(TAMANO_CELDA, TAMANO_CELDA)
				resaltado.position = Vector2(celda_pos_x(x), celda_pos_y(y))
				resaltado.color = color_seleccionable
				resaltado.z_index = 5
				tablero_visual.add_child(resaltado)
				fichas_resaltadas.append(resaltado)

func limpiar_resaltado():
	for r in fichas_resaltadas:
		if is_instance_valid(r):
			r.queue_free()
	fichas_resaltadas.clear()

# ====== CURSOR DE PODER (sigue el mouse exacto) ======
func crear_cursor_poder():
	if cursor_poder_label != null and is_instance_valid(cursor_poder_label):
		cursor_poder_label.queue_free()
	cursor_poder_label = null

func actualizar_cursor_poder(mouse_pos):
	# Si no hay cursor o cambió de tipo, recrear
	if cursor_poder_label == null or not is_instance_valid(cursor_poder_label):
		var script_path = ""
		match poder_seleccionado:
			"BOMBA":
				script_path = "res://efectos/cursor_bomba.gd"
			"HIELO":
				script_path = "res://efectos/cursor_hielo.gd"
			_:
				return
		
		cursor_poder_label = Node2D.new()
		cursor_poder_label.set_script(load(script_path))
		cursor_poder_label.name = "CursorPoder"
		cursor_poder_label.z_index = 100
		capa_ui.add_child(cursor_poder_label)
	
	cursor_poder_label.position = mouse_pos
	cursor_poder_label.visible = true

func ocultar_cursor_poder():
	if cursor_poder_label != null and is_instance_valid(cursor_poder_label):
		cursor_poder_label.queue_free()
		cursor_poder_label = null

# ====== PREVIEW DE FICHA SOBRE EL TABLERO ======
func crear_preview_ficha():
	# Siempre destruir el anterior para evitar color incorrecto
	if preview_ficha != null:
		preview_ficha.queue_free()
		preview_ficha = null
	
	preview_ficha = ficha_escena.instantiate()
	preview_ficha.size = Vector2(TAMANO_CELDA + 2, TAMANO_CELDA + 2)
	preview_ficha.configurar(turno_actual)
	preview_ficha.modulate = Color(1, 1, 1, 0.5)
	preview_ficha.z_index = 15
	preview_ficha.visible = false
	tablero_visual.add_child(preview_ficha)
	preview_columna_actual = -1

func destruir_preview():
	if preview_ficha != null:
		preview_ficha.queue_free()
		preview_ficha = null
		preview_columna_actual = -1

func actualizar_preview(mouse_x):
	if preview_ficha == null:
		return
	
	var col = -1
	var ancho_tablero = COLUMNAS * (TAMANO_CELDA + ESPACIO) + ESPACIO
	
	if mouse_x >= tablero_x and mouse_x <= tablero_x + ancho_tablero:
		col = int((mouse_x - tablero_x - ESPACIO) / float(TAMANO_CELDA + ESPACIO))
		col = clamp(col, 0, COLUMNAS - 1)
	
	# Fuera del tablero: ocultar
	if col == -1:
		preview_ficha.visible = false
		preview_columna_actual = -1
		return
	
	# Columna congelada o llena: ocultar completamente
	if esta_columna_congelada(col) or buscar_fila_disponible(col) == -1:
		preview_ficha.visible = false
		preview_columna_actual = -1
		return
	
	# Columna válida: mostrar preview
	if col != preview_columna_actual:
		preview_columna_actual = col
		var pos_x = celda_pos_x(col) - 1
		var pos_y = tablero_y - TAMANO_CELDA - 10
		preview_ficha.position = Vector2(pos_x, pos_y)
	
	preview_ficha.modulate = Color(1, 1, 1, 0.5)
	preview_ficha.visible = true
	
# ====== RELOJ VISUAL ======
# ====== RELOJ VISUAL ======
func _process(_delta):
	if fase_juego == "PREGUNTA" and temporizador.time_left > 0:
		var tiempo_restante = int(ceil(temporizador.time_left))
		texto_reloj.text = str(tiempo_restante)
		
		# --- NUEVO: CUENTA REGRESIVA ---
		if tiempo_restante <= 6 and tiempo_restante != ultimo_segundo_reloj:
			# Si justo acabamos de entrar al segundo 6, reproducimos el audio largo UNA vez
			if tiempo_restante == 6:
				reproductor_tick.stream = snd_tick
				reproductor_tick.play()

			ultimo_segundo_reloj = tiempo_restante
			# Efecto de tensión: Cambia de amarillo a naranja, y a rojo en los últimos 3 segundos
			if tiempo_restante <= 3:
				texto_reloj.add_theme_color_override("font_color", Color(1, 0.2, 0.2)) # Rojo intenso
			else:
				texto_reloj.add_theme_color_override("font_color", Color(0.878, 0.146, 0.471, 1.0)) # Naranja
	
	if fase_juego == "LANZAMIENTO" and not juego_pausado:
		var mouse_pos = get_viewport().get_mouse_position()
		
		if poder_seleccionado == "NINGUNO":
			if preview_ficha == null or not is_instance_valid(preview_ficha):
				preview_ficha = null
				crear_preview_ficha()
			actualizar_preview(mouse_pos.x)
			if _cursor_tipo_actual != "":
				ocultar_cursor_poder()
				_cursor_tipo_actual = ""
		else:
			if preview_ficha != null:
				preview_ficha.visible = false
			if _cursor_tipo_actual != poder_seleccionado:
				ocultar_cursor_poder()
				_cursor_tipo_actual = poder_seleccionado
			actualizar_cursor_poder(mouse_pos)
	else:
		if preview_ficha != null:
			preview_ficha.visible = false
		if _cursor_tipo_actual != "":
			ocultar_cursor_poder()
			_cursor_tipo_actual = ""

# ====== DETECTAR CLICS Y TECLAS ======
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		toggle_pausa()
		return
	
	# --- Alternar Pantalla Completa con F11 ---
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		_on_toggle_fullscreen()
		return
	
	# Si está pausado, no procesar nada más
	if juego_pausado:
		return
	
	if juego_terminado:
		return
	
	# Atajos de teclado
	if fase_juego == "LANZAMIENTO" and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_on_seleccionar_normal()
			KEY_2:
				var tiene = bombas_j1 if turno_actual == 1 else bombas_j2
				if tiene > 0:
					_on_seleccionar_bomba()
			KEY_3:
				var tiene = hielos_j1 if turno_actual == 1 else hielos_j2
				if tiene > 0:
					_on_seleccionar_hielo()
			KEY_ESCAPE:
				_on_cancelar_poder()
	
	# Clics
	if fase_juego != "LANZAMIENTO":
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mx = event.position.x
		var my = event.position.y
		
		# Ignorar zona de botones de poder
		if my < 60:
			return
		
		var ancho_tablero = COLUMNAS * (TAMANO_CELDA + ESPACIO) + ESPACIO
		var alto_tablero = FILAS * (TAMANO_CELDA + ESPACIO) + ESPACIO
		
		if mx >= tablero_x and mx <= tablero_x + ancho_tablero:
			if my >= tablero_y and my <= tablero_y + alto_tablero:
				var columna = int((mx - tablero_x - ESPACIO) / float(TAMANO_CELDA + ESPACIO))
				var fila = int((my - tablero_y - ESPACIO) / float(TAMANO_CELDA + ESPACIO))
				columna = clamp(columna, 0, COLUMNAS - 1)
				fila = clamp(fila, 0, FILAS - 1)
				
				ejecutar_accion(columna, fila)

func ejecutar_accion(columna, fila):
	match poder_seleccionado:
		"NINGUNO":
			if esta_columna_congelada(columna):
				print("¡Columna congelada!")
				return
			lanzar_ficha(columna)
		"BOMBA":
			usar_bomba(columna, fila)
		"HIELO":
			if esta_columna_congelada(columna):
				print("¡Ya está congelada!")
				return
			usar_hielo(columna)

func esta_columna_congelada(columna):
	for info in columnas_congeladas_info:
		if info["columna"] == columna:
			return true
	return false

# ====== CONECTAR BOTONES TRIVIA ======
func conectar_botones_trivia():
	var botones = contenedor_botones.get_children()
	for i in range(botones.size()):
		botones[i].pressed.connect(_on_boton_trivia_presionado.bind(i))
		agregar_hover_sonido_juego(botones[i])

# ====== TURNOS ======
func iniciar_turno():
	if juego_terminado:
		return
		
	destruir_preview()
	ocultar_cursor_poder()
	var se_descongelo_algo = verificar_descongelamiento()
	if se_descongelo_algo:
			# Si tras descongelar alguien tiene 4 en línea, el juego termina inmediatamente
			if verificar_victoria_completa():
				return

	actualizar_opacidad_jugadores()

	fase_juego = "PREGUNTA"
	pantalla_pregunta.show()
	ocultar_botones_poder()
	
	if label_turno:
		var color_txt = "ROJO" if turno_actual == 1 else "AMARILLO"
		label_turno.text = "Turno: Jugador " + str(turno_actual) + " " + color_txt
	
	mostrar_pregunta_aleatoria()

func actualizar_opacidad_jugadores():
	if turno_actual == 1:
		label_inventario_j1.modulate = Color(1, 1, 1, 1.0)   # Totalmente visible
		label_inventario_j2.modulate = Color(1, 1, 1, 0.3)   # Transparente
	else:
		label_inventario_j1.modulate = Color(1, 1, 1, 0.3)   # Transparente
		label_inventario_j2.modulate = Color(1, 1, 1, 1.0)   # Totalmente visible

func verificar_descongelamiento():
	var columnas_a_quitar = []
	
	for info in columnas_congeladas_info:
		if info["puesto_por"] == turno_actual:
			columnas_a_quitar.append(info)
	
	var hubo_descongelamiento = columnas_a_quitar.size() > 0

	for info in columnas_a_quitar:
		var col = info["columna"]
		
		# Restaurar celdas vacías
		for fila in range(FILAS):
			var celda = tablero_visual.get_node_or_null("Celda_" + str(col) + "_" + str(fila))
			if celda and matriz_tablero[col][fila] == 0:
				celda.set_color(color_celda_vacia)
		
		# Quitar overlays de hielo
		quitar_overlays_hielo(col)
		
		var flecha = tablero_visual.get_node_or_null("Flecha_" + str(col))
		if flecha:
			flecha.text = "▼"
			flecha.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
		
		columnas_congeladas_info.erase(info)
	return hubo_descongelamiento # Devuelve true si quitó hielo


func mostrar_pregunta_aleatoria():
	if preguntas_activas.size() == 0:
		preguntas_activas = preguntas_base.duplicate(true)
	
	# Limpiar botones extras de victoria/empate
	var btn_menu_extra = pantalla_pregunta.get_node_or_null("BtnMenuVictoria")
	if btn_menu_extra:
		btn_menu_extra.queue_free()
	var btn_continuar_extra = pantalla_pregunta.get_node_or_null("BotonContinuar")
	if btn_continuar_extra:
		btn_continuar_extra.queue_free()
	
	# Restaurar tamaño de fuente normal (Aumentado a 16 para coincidir)
	TemaPixel.aplicar_fuente_label(texto_pregunta, 15)
	TemaPixel.aplicar_fuente_label(texto_reloj, 23)
	texto_reloj.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ultimo_segundo_reloj = -1
	
	var indice = randi() % preguntas_activas.size()
	# Usamos duplicate(true) para no modificar la base de datos original al mezclar
	pregunta_actual = preguntas_activas[indice].duplicate(true)
	preguntas_activas.remove_at(indice)
	
	aplicar_color_pregunta_jugador()

	var icono = "[P1]" if turno_actual == 1 else "[P2]"
	texto_pregunta.text = icono + " " + pregunta_actual["pregunta"]
	
	# 1. Obtenemos cuál era el texto exacto de la respuesta correcta
	var texto_respuesta_correcta = pregunta_actual["opciones"][pregunta_actual["correcta"]]
	
	# 2. Hacemos una copia del arreglo de opciones y lo mezclamos aleatoriamente
	var opciones_mezcladas = pregunta_actual["opciones"].duplicate()
	opciones_mezcladas.shuffle()
	
	# 3. Actualizamos la pregunta con las opciones ya mezcladas
	pregunta_actual["opciones"] = opciones_mezcladas
	
	# 4. Buscamos en qué nuevo índice (0, 1, 2 o 3) quedó la respuesta correcta
	pregunta_actual["correcta"] = opciones_mezcladas.find(texto_respuesta_correcta)
	# -----------------------------------
	
	var botones = contenedor_botones.get_children()
	for i in range(4):
		botones[i].text = pregunta_actual["opciones"][i]
		botones[i].show()
		botones[i].custom_minimum_size = Vector2(0, 45)
	
	temporizador.start(20.0)

# ====== RESPUESTAS ======
func _on_boton_trivia_presionado(indice_boton):
	_on_boton_trivia_presionado
	if fase_juego != "PREGUNTA":
		return
	temporizador.stop()
	
	if indice_boton == pregunta_actual["correcta"]:
		reproducir_ui(snd_correcto)
		manejar_acierto()
	else:
		reproducir_ui(snd_incorrecto)
		manejar_fallo()

func _on_tiempo_agotado():
	reproductor_tick.stop()
	if fase_juego != "PREGUNTA":
		return
	reproducir_ui(snd_incorrecto)

	if turno_actual == 1:
		racha_j1 = 0
	else:
		racha_j2 = 0
	
	texto_pregunta.text = "[!] TIEMPO AGOTADO!\n\nIntentalo mas rapido"
	texto_reloj.text = "--"
	TemaPixel.aplicar_fuente_label(texto_reloj, 30)
	
	for boton in contenedor_botones.get_children():
		boton.hide()
	
	var boton_continuar = Button.new()
	boton_continuar.name = "BotonContinuar"
	boton_continuar.text = "CONTINUAR >>"
	boton_continuar.position = Vector2(280, 320)
	boton_continuar.size = Vector2(240, 55)
	aplicar_boton_pixel_juego(boton_continuar, Color(0.12, 0.12, 0.3), Color(0.3, 0.5, 0.9), 11)
	boton_continuar.pressed.connect(_on_continuar_despues_error.bind(boton_continuar))
	agregar_hover_sonido_juego(boton_continuar)
	pantalla_pregunta.add_child(boton_continuar)

func mostrar_mensaje_error():
	var respuesta_correcta = pregunta_actual["opciones"][pregunta_actual["correcta"]]
	texto_pregunta.text = "[X] INCORRECTO!\n\nRespuesta correcta:\n" + respuesta_correcta
	texto_reloj.text = "><"
	TemaPixel.aplicar_fuente_label(texto_reloj, 30)
	
	for boton in contenedor_botones.get_children():
		boton.hide()
	
	var boton_continuar = Button.new()
	boton_continuar.name = "BotonContinuar"
	boton_continuar.text = "CONTINUAR >>"
	boton_continuar.position = Vector2(280, 320)
	boton_continuar.size = Vector2(240, 55)
	aplicar_boton_pixel_juego(boton_continuar, Color(0.12, 0.12, 0.3), Color(0.3, 0.5, 0.9), 11)
	boton_continuar.pressed.connect(_on_continuar_despues_error.bind(boton_continuar))
	agregar_hover_sonido_juego(boton_continuar)
	pantalla_pregunta.add_child(boton_continuar)

func manejar_acierto():
	fase_juego = "LANZAMIENTO"
	pantalla_pregunta.hide()
	mostrar_botones_poder()
	
	if turno_actual == 1:
		racha_j1 += 1
		if racha_j1 >= 2:
			otorgar_poder_aleatorio(1)
			racha_j1 = 0
	else:
		racha_j2 += 1
		if racha_j2 >= 2:
			otorgar_poder_aleatorio(2)
			racha_j2 = 0
	
	actualizar_inventario()

func otorgar_poder_aleatorio(jugador):
	var poder = ["BOMBA", "HIELO"].pick_random()
	
	if jugador == 1:
		if poder == "BOMBA":
			bombas_j1 += 1
		else:
			hielos_j1 += 1
	else:
		if poder == "BOMBA":
			bombas_j2 += 1
		else:
			hielos_j2 += 1
	
	# Notificación visual
	var icono_poder = "BOMBA" if poder == "BOMBA" else "HIELO"
	var icono_jugador = "P1" if jugador == 1 else "P2"
	mostrar_notificacion(icono_jugador + " ¡Jugador " + str(jugador) + " ganó " + icono_poder + "!")
	
	mostrar_botones_poder()

func manejar_fallo():
	if turno_actual == 1:
		racha_j1 = 0
	else:
		racha_j2 = 0
	
	# Mostrar mensaje de error
	mostrar_mensaje_error()

func _on_continuar_despues_error(boton):
	# Eliminar el botón de continuar
	boton.queue_free()
	
	# Cambiar turno
	cambiar_turno()

# ====== LANZAR FICHA NORMAL ======
func lanzar_ficha(columna):
	var fila = buscar_fila_disponible(columna)
	
	if fila == -1:
		print("¡Columna llena!")
		return
	
	fase_juego = "ANIMANDO"
	destruir_preview()
	matriz_tablero[columna][fila] = turno_actual
	
	var nueva_ficha = ficha_escena.instantiate()
	nueva_ficha.z_index = 5 # La ficha al caer viaja por DETRÁS de las celdas (que tienen z_index=10)

	nueva_ficha.position = Vector2(celda_pos_x(columna) - 1, tablero_y - TAMANO_CELDA)
	nueva_ficha.size = Vector2(TAMANO_CELDA + 2, TAMANO_CELDA + 2)
	nueva_ficha.configurar(turno_actual)
	#nueva_ficha.queue_redraw()  # Forzar que se dibuje el círculo
	tablero_visual.add_child(nueva_ficha)
	
	fichas_visuales[columna][fila] = nueva_ficha
	
	var destino_y = celda_pos_y(fila) - 1
	nueva_ficha.animar_caida(destino_y)
	
	# Sonido de ficha cayendo según la fila
	reproducir_ficha(fila)
	
	ocultar_botones_poder()
	
	await get_tree().create_timer(0.6).timeout
	
	if verificar_victoria(columna, fila, turno_actual):
		juego_terminado = true
		fase_juego = "FIN"
		mostrar_victoria()
		return
	
	if tablero_lleno():
		juego_terminado = true
		fase_juego = "FIN"
		mostrar_empate()
		return
	
	cambiar_turno()

# ====== USAR BOMBA (seleccionar ficha específica) ======
func usar_bomba(columna, fila):
	var enemigo = 2 if turno_actual == 1 else 1
	
	# Verificar si la columna está congelada
	if esta_columna_congelada(columna):
		mostrar_notificacion("❄️ ¡Columna congelada! No puedes usar bomba ahí")
		return
	
	# Retroalimentación si la celda no es válida
	if matriz_tablero[columna][fila] == 0:
		mostrar_notificacion("[!] Casilla vacia! Elige una ficha enemiga")
		return
	
	if matriz_tablero[columna][fila] == turno_actual:
		mostrar_notificacion("[!] Esa ficha es tuya! Elige una enemiga")
		return
	
	# Verificar que la celda seleccionada tiene ficha enemiga
	if matriz_tablero[columna][fila] != enemigo:
		print("[!] Selecciona una ficha del oponente")
		return
	
	fase_juego = "ANIMANDO"
	destruir_preview()
	ocultar_cursor_poder()
	# Destruir la ficha seleccionada
	matriz_tablero[columna][fila] = 0
	
	if fichas_visuales[columna][fila] != null:
		var ficha = fichas_visuales[columna][fila]
		crear_explosion(ficha.position + Vector2(float(TAMANO_CELDA / 2), float(TAMANO_CELDA / 2)))
		reproducir_efecto(snd_explosion)
		ficha.queue_free()
		fichas_visuales[columna][fila] = null
	
	# Descontar bomba
	if turno_actual == 1:
		bombas_j1 -= 1
	else:
		bombas_j2 -= 1
	
	limpiar_resaltado()
	actualizar_inventario()
	ocultar_botones_poder()
	
	# Esperar y aplicar gravedad
	await get_tree().create_timer(0.3).timeout
	await aplicar_gravedad(columna)
	
	# Verificar si la gravedad creó un 4 en línea
	await get_tree().create_timer(0.3).timeout
	if verificar_victoria_completa():
		return
	
	cambiar_turno()

# ====== GRAVEDAD: hacer caer fichas después de destruir una ======
func aplicar_gravedad(columna):
	# Recorrer desde abajo hacia arriba
	var hubo_cambio = true
	
	while hubo_cambio:
		hubo_cambio = false
		
		# Desde la penúltima fila hacia arriba
		for y in range(FILAS - 2, -1, -1):
			# Si esta celda tiene ficha y la de abajo está vacía
			if matriz_tablero[columna][y] != 0 and matriz_tablero[columna][y + 1] == 0:
				# Mover en la matriz
				matriz_tablero[columna][y + 1] = matriz_tablero[columna][y]
				matriz_tablero[columna][y] = 0
				
				# Mover visualmente
				var ficha = fichas_visuales[columna][y]
				fichas_visuales[columna][y + 1] = ficha
				fichas_visuales[columna][y] = null
				
				if ficha != null:
					var destino_y = celda_pos_y(y + 1) - 1
					var tween = create_tween()
					tween.tween_property(ficha, "position:y", destino_y, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
				
				hubo_cambio = true
		
		if hubo_cambio:
			await get_tree().create_timer(0.25).timeout

func verificar_victoria_completa():
	# Revisamos primero al jugador de este turno, y luego al oponente
	var jugadores_a_revisar = [turno_actual, 2 if turno_actual == 1 else 1]
	
	for j in jugadores_a_revisar:
		for x in range(COLUMNAS):
			for y in range(FILAS):
				if matriz_tablero[x][y] == j:
					if verificar_victoria(x, y, j):
						# Si alguien gana de forma pasiva, asignamos su turno para la UI
						turno_actual = j 
						juego_terminado = true
						fase_juego = "FIN"
						print("¡¡¡JUGADOR ", j, " GANA POR EFECTO EN TABLERO!!!")
						mostrar_victoria()
						return true
	return false

func crear_explosion(centro):
	var ExplosionScript = preload("res://efectos/explosion_pixel.gd")
	var explosion = Node2D.new()
	explosion.set_script(ExplosionScript)
	explosion.position = centro
	tablero_visual.add_child(explosion)

# ====== OVERLAY DE HIELO EN CELDAS ======
func agregar_overlay_hielo_celda(col, fila):
	var HieloScript = preload("res://efectos/hielo_overlay.gd")
	var overlay = Control.new()
	overlay.set_script(HieloScript)
	overlay.name = "HieloOverlay_" + str(col) + "_" + str(fila)
	overlay.size = Vector2(TAMANO_CELDA, TAMANO_CELDA)
	overlay.position = Vector2(celda_pos_x(col), celda_pos_y(fila))
	tablero_visual.add_child(overlay)

func quitar_overlays_hielo(col):
	for fila in range(FILAS):
		var overlay = tablero_visual.get_node_or_null("HieloOverlay_" + str(col) + "_" + str(fila))
		if overlay:
			overlay.queue_free()

func efecto_congelamiento(col):
	var CongelarScript = preload("res://efectos/congelamiento_efecto.gd")
	var efecto = Node2D.new()
	efecto.set_script(CongelarScript)
	var x = celda_pos_x(col)
	var y = celda_pos_y(0)
	var alto = FILAS * (TAMANO_CELDA + ESPACIO)
	efecto.iniciar(x, y, TAMANO_CELDA, alto)
	tablero_visual.add_child(efecto)

# ====== USAR HIELO ======
func usar_hielo(columna):
	if esta_columna_congelada(columna):
		print("[!] Ya está congelada!")
		return
	
	columnas_congeladas_info.append({
		"columna": columna,
		"puesto_por": turno_actual
	})
	
	if turno_actual == 1:
		hielos_j1 -= 1
	else:
		hielos_j2 -= 1
	
	# Cambiar color de celdas vacías y agregar overlays
	for fila in range(FILAS):
		var celda = tablero_visual.get_node_or_null("Celda_" + str(columna) + "_" + str(fila))
		if celda and matriz_tablero[columna][fila] == 0:
			celda.set_color(color_celda_congelada)
		# Overlay en TODAS las celdas (vacías y con fichas)
		agregar_overlay_hielo_celda(columna, fila)
	
	var flecha = tablero_visual.get_node_or_null("Flecha_" + str(columna))
	if flecha:
		flecha.text = "❄️"
		flecha.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
	
	# Efecto visual de congelamiento
	efecto_congelamiento(columna)
	actualizar_inventario()
	reproducir_efecto(snd_congelado)
	ocultar_cursor_poder()
	
	# Volver a modo normal
	poder_seleccionado = "NINGUNO"
	boton_cancelar.hide()
	label_poder_activo.show()
	label_poder_activo.text = "Lanza tu ficha"
	label_poder_activo.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	boton_hielo.disabled = true
	boton_bomba.disabled = true

# ====== BUSCAR FILA ======
func buscar_fila_disponible(columna):
	for y in range(FILAS - 1, -1, -1):
		if matriz_tablero[columna][y] == 0:
			return y
	return -1

# ====== VERIFICAR VICTORIA ======
func verificar_victoria(columna, fila, jugador):
	# Si la ficha desde la que revisamos está congelada, no hay victoria posible
	if esta_columna_congelada(columna):
		return false
		
	var direcciones = [
		[Vector2i(1, 0), Vector2i(-1, 0)],
		[Vector2i(0, 1), Vector2i(0, -1)],
		[Vector2i(1, 1), Vector2i(-1, -1)],
		[Vector2i(1, -1), Vector2i(-1, 1)]
	]
	for dir in direcciones:
		var fichas_linea = [Vector2i(columna, fila)]
		fichas_linea += obtener_fichas_en_direccion(columna, fila, dir[0].x, dir[0].y, jugador)
		fichas_linea += obtener_fichas_en_direccion(columna, fila, dir[1].x, dir[1].y, jugador)
		if fichas_linea.size() >= 4:
			fichas_ganadoras = fichas_linea
			return true
	return false

func animar_fichas_ganadoras():
	for pos in fichas_ganadoras:
		var ficha = fichas_visuales[pos.x][pos.y]
		if ficha != null:
			# Parpadeo
			var tween = create_tween().set_loops(8)
			tween.tween_property(ficha, "modulate:a", 0.2, 0.3)
			tween.tween_property(ficha, "modulate:a", 1.0, 0.3)
			
			# Efecto de brillo en cada ficha ganadora
			var brillo = ColorRect.new()
			brillo.size = Vector2(TAMANO_CELDA + 6, TAMANO_CELDA + 6)
			brillo.position = Vector2(celda_pos_x(pos.x) - 3, celda_pos_y(pos.y) - 3)
			brillo.color = Color(1, 1, 1, 0.0)
			brillo.z_index = 9
			tablero_visual.add_child(brillo)
			
			var tween_brillo = create_tween().set_loops(4)
			tween_brillo.tween_property(brillo, "color:a", 0.4, 0.4)
			tween_brillo.tween_property(brillo, "color:a", 0.0, 0.4)
			
			# Eliminar brillo después
			var tween_clean = create_tween()
			tween_clean.tween_interval(4.0)
			tween_clean.tween_callback(brillo.queue_free)

func crear_confeti():
	var colores_confeti = [
		Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1),
		Color(1, 1, 0), Color(1, 0, 1), Color(0, 1, 1),
		Color(1, 0.5, 0), Color(0.5, 0, 1)
	]
	
	for i in range(40):
		var confeti = ColorRect.new()
		confeti.size = Vector2(randf_range(6, 14), randf_range(6, 14))
		confeti.color = colores_confeti[randi() % colores_confeti.size()]
		confeti.position = Vector2(randf_range(200, 950), -20)
		confeti.z_index = 20
		tablero_visual.add_child(confeti)
		
		var tween = create_tween()
		var destino_x = confeti.position.x + randf_range(-100, 100)
		var destino_y = randf_range(400, 700)
		var duracion = randf_range(1.0, 2.5)
		
		tween.tween_property(confeti, "position", Vector2(destino_x, destino_y), duracion).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(confeti, "rotation", randf_range(-10, 10), duracion)
		tween.tween_property(confeti, "modulate:a", 0.0, 0.5)
		tween.tween_callback(confeti.queue_free)

func obtener_fichas_en_direccion(col, fil, dx, dy, jugador):
	var fichas = []
	var x = col + dx
	var y = fil + dy
	while x >= 0 and x < COLUMNAS and y >= 0 and y < FILAS:
		# Si chocamos con una columna congelada, la línea se rompe de inmediato
		if esta_columna_congelada(x):
			break
		
		if matriz_tablero[x][y] == jugador:
			fichas.append(Vector2i(x, y))
			x += dx
			y += dy
		else:
			break
	return fichas

func tablero_lleno():
	for x in range(COLUMNAS):
		if matriz_tablero[x][0] == 0:
			return false
	return true

# ====== RESULTADOS ======
func mostrar_victoria():
	destruir_preview()
	ocultar_cursor_poder()
	ocultar_botones_poder()
	
	var btn_pausa = capa_ui.get_node_or_null("BotonPausa")
	if btn_pausa:
		btn_pausa.hide()
	var btn_musica = capa_ui.get_node_or_null("BotonMusica")
	if btn_musica:
		btn_musica.hide()
	
	animar_fichas_ganadoras()
	reproducir_efecto(snd_victoria)
	
	var VictoriaScript = preload("res://efectos/victoria_efecto.gd")
	var efecto_victoria = Node2D.new()
	efecto_victoria.set_script(VictoriaScript)
	tablero_visual.add_child(efecto_victoria)
	
	var TextoScript = preload("res://efectos/texto_victoria.gd")
	var texto_vic = Node2D.new()
	texto_vic.set_script(TextoScript)
	texto_vic.position = Vector2(576, 80)
	var jugador_txt = "P1 ROJO" if turno_actual == 1 else "P2 AMARILLO"
	texto_vic.texto = jugador_txt + " GANA!"
	texto_vic.color_texto = Color(1, 0.3, 0.3) if turno_actual == 1 else Color(1, 0.85, 0.1)
	tablero_visual.add_child(texto_vic)
	
	await get_tree().create_timer(3.0).timeout
	
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
	
	var color_nombre = Color(1, 0.3, 0.3) if turno_actual == 1 else Color(1, 0.85, 0.1)
	var ganador_nombre = "P" + str(turno_actual) + " " + ("ROJO" if turno_actual == 1 else "AMARILLO")
	
	# Textos centrados
	texto_pregunta.text = "VICTORIA!"
	texto_pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TemaPixel.aplicar_fuente_label(texto_pregunta, 30)
	texto_pregunta.add_theme_color_override("font_color", color_nombre)
	
	texto_reloj.text = ganador_nombre + "\nGANA!"
	texto_reloj.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TemaPixel.aplicar_fuente_label(texto_reloj, 18)
	texto_reloj.add_theme_color_override("font_color", Color(1, 1, 1))
	
	for boton in contenedor_botones.get_children():
		boton.hide()
	
	# Ocultar botón reiniciar original
	boton_reiniciar.hide()
	
	pantalla_pregunta.show()
	
	# Calcular centro del panel
	var pw = pantalla_pregunta.size.x
	var btn_ancho = 300
	var btn_x = (pw - btn_ancho) / 2.0
	
	# Botón "Jugar de nuevo" dentro del panel
	var btn_jugar_nuevo = Button.new()
	btn_jugar_nuevo.name = "BtnJugarNuevoVic"
	btn_jugar_nuevo.text = "JUGAR DE NUEVO"
	btn_jugar_nuevo.position = Vector2(btn_x, pantalla_pregunta.size.y - 170)
	btn_jugar_nuevo.size = Vector2(btn_ancho, 55)
	aplicar_boton_pixel_juego(btn_jugar_nuevo, Color(0.06, 0.38, 0.12), Color(0.15, 0.85, 0.25), 12)
	btn_jugar_nuevo.pressed.connect(_on_reiniciar)
	agregar_hover_sonido_juego(btn_jugar_nuevo)
	pantalla_pregunta.add_child(btn_jugar_nuevo)
	
	# Botón "Menú Principal" dentro del panel
	var btn_ancho2 = 260
	var btn_x2 = (pw - btn_ancho2) / 2.0
	var btn_menu_vic = Button.new()
	btn_menu_vic.name = "BtnMenuVictoria"
	btn_menu_vic.text = "MENU PRINCIPAL"
	btn_menu_vic.position = Vector2(btn_x2, pantalla_pregunta.size.y - 100)
	btn_menu_vic.size = Vector2(btn_ancho2, 45)
	aplicar_boton_pixel_juego(btn_menu_vic, Color(0.3, 0.08, 0.08), Color(0.75, 0.25, 0.25), 11)
	btn_menu_vic.pressed.connect(_on_ir_menu_principal)
	agregar_hover_sonido_juego(btn_menu_vic)
	pantalla_pregunta.add_child(btn_menu_vic)

func mostrar_empate():
	destruir_preview()
	ocultar_cursor_poder()
	ocultar_botones_poder()
	
	var btn_pausa = capa_ui.get_node_or_null("BotonPausa")
	if btn_pausa:
		btn_pausa.hide()
	var btn_musica = capa_ui.get_node_or_null("BotonMusica")
	if btn_musica:
		btn_musica.hide()
	
	reproducir_efecto(snd_empate)
	
	var TextoScript = preload("res://efectos/texto_victoria.gd")
	var texto_emp = Node2D.new()
	texto_emp.set_script(TextoScript)
	texto_emp.position = Vector2(576, 80)
	texto_emp.texto = "EMPATE!"
	texto_emp.color_texto = Color(0.7, 0.7, 0.8)
	tablero_visual.add_child(texto_emp)
	
	await get_tree().create_timer(2.0).timeout
	
	if pantalla_pregunta is Panel:
		pantalla_pregunta.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
			Color(0.08, 0.08, 0.14, 0.97), Color(0.5, 0.5, 0.6)
		))
	
	texto_pregunta.text = "EMPATE!"
	texto_pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TemaPixel.aplicar_fuente_label(texto_pregunta, 30)
	texto_pregunta.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9))
	
	texto_reloj.text = "Nadie gano\nesta ronda"
	texto_reloj.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TemaPixel.aplicar_fuente_label(texto_reloj, 14)
	texto_reloj.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	
	for boton in contenedor_botones.get_children():
		boton.hide()
	
	boton_reiniciar.hide()
	pantalla_pregunta.show()
	
	var pw = pantalla_pregunta.size.x
	var btn_ancho = 300
	var btn_x = (pw - btn_ancho) / 2.0
	
	var btn_jugar_nuevo = Button.new()
	btn_jugar_nuevo.name = "BtnJugarNuevoVic"
	btn_jugar_nuevo.text = "JUGAR DE NUEVO"
	btn_jugar_nuevo.position = Vector2(btn_x, pantalla_pregunta.size.y - 170)
	btn_jugar_nuevo.size = Vector2(btn_ancho, 55)
	aplicar_boton_pixel_juego(btn_jugar_nuevo, Color(0.06, 0.38, 0.12), Color(0.15, 0.85, 0.25), 12)
	btn_jugar_nuevo.pressed.connect(_on_reiniciar)
	agregar_hover_sonido_juego(btn_jugar_nuevo)
	pantalla_pregunta.add_child(btn_jugar_nuevo)
	
	var btn_ancho2 = 260
	var btn_x2 = (pw - btn_ancho2) / 2.0
	var btn_menu_emp = Button.new()
	btn_menu_emp.name = "BtnMenuVictoria"
	btn_menu_emp.text = "MENU PRINCIPAL"
	btn_menu_emp.position = Vector2(btn_x2, pantalla_pregunta.size.y - 100)
	btn_menu_emp.size = Vector2(btn_ancho2, 45)
	aplicar_boton_pixel_juego(btn_menu_emp, Color(0.3, 0.08, 0.08), Color(0.75, 0.25, 0.25), 11)
	btn_menu_emp.pressed.connect(_on_ir_menu_principal)
	agregar_hover_sonido_juego(btn_menu_emp)
	pantalla_pregunta.add_child(btn_menu_emp)

# ====== REINICIAR JUEGO ======
func _on_reiniciar():
	Global.reproducir_transicion(snd_retirar_fichas)
	Global.abrir_categorias = true
	get_tree().change_scene_to_file("res://menu_principal.tscn")

# "Menú principal" → va al menú normal
func _on_ir_menu_principal():
	Global.reproducir_transicion(snd_retirar_fichas)
	Global.abrir_categorias = false
	get_tree().change_scene_to_file("res://menu_principal.tscn")
	
func cambiar_turno():
	turno_actual = 2 if turno_actual == 1 else 1
	iniciar_turno()

func agregar_hover_sonido_juego(boton):
	boton.mouse_entered.connect(_on_hover_boton_juego)

func _on_hover_boton_juego():
	sonido_ui.stream = preload("res://sonidos/hover1.wav")
	sonido_ui.play()

func crear_menu_pausa():
	panel_pausa = Control.new()
	panel_pausa.name = "PanelPausa"
	panel_pausa.z_index = 100
	panel_pausa.hide()
	capa_ui.add_child(panel_pausa)
	
	var fondo = ColorRect.new()
	fondo.position = Vector2(0, 0)
	fondo.size = Vector2(1152, 648)
	fondo.color = Color(0, 0, 0, 0.8)
	panel_pausa.add_child(fondo)
	
	var ventana = Panel.new()
	ventana.position = Vector2(376, 150)
	ventana.size = Vector2(400, 350)
	ventana.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.06, 0.06, 0.18, 0.98),
		Color(0.3, 0.45, 0.8)
	))
	panel_pausa.add_child(ventana)
	
	var titulo = Label.new()
	titulo.text = "PAUSA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(100, 25)
	titulo.size = Vector2(200, 40)
	TemaPixel.aplicar_fuente_label(titulo, 24)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	ventana.add_child(titulo)
	
	var btn_continuar = Button.new()
	btn_continuar.text = "CONTINUAR"
	btn_continuar.position = Vector2(100, 95)
	btn_continuar.size = Vector2(200, 50)
	aplicar_boton_pixel_juego(btn_continuar, Color(0.08, 0.4, 0.15), Color(0.2, 0.9, 0.3), 12)
	btn_continuar.pressed.connect(_on_pausa_continuar)
	agregar_hover_sonido_juego(btn_continuar)
	ventana.add_child(btn_continuar)
	
	var btn_reiniciar_pausa = Button.new()
	btn_reiniciar_pausa.text = "REINICIAR"
	btn_reiniciar_pausa.position = Vector2(100, 165)
	btn_reiniciar_pausa.size = Vector2(200, 50)
	aplicar_boton_pixel_juego(btn_reiniciar_pausa, Color(0.35, 0.25, 0.05), Color(0.8, 0.6, 0.1), 12)
	btn_reiniciar_pausa.pressed.connect(_on_pausa_reiniciar)
	agregar_hover_sonido_juego(btn_reiniciar_pausa)
	ventana.add_child(btn_reiniciar_pausa)
	
	var btn_menu = Button.new()
	btn_menu.text = "MENU"
	btn_menu.position = Vector2(100, 235)
	btn_menu.size = Vector2(200, 50)
	aplicar_boton_pixel_juego(btn_menu, Color(0.4, 0.08, 0.08), Color(1, 0.3, 0.3), 12)
	btn_menu.pressed.connect(_on_pausa_menu)
	agregar_hover_sonido_juego(btn_menu)
	ventana.add_child(btn_menu)
	
	panel_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Botón de pausa con ÍCONO pixel art
	var btn_pausa = Button.new()
	btn_pausa.name = "BotonPausa"
	btn_pausa.text = ""
	btn_pausa.position = Vector2(10, 10)
	btn_pausa.size = Vector2(45, 45)
	btn_pausa.z_index = 50
	var estilos_pausa = TemaPixel.crear_boton_pixel(
		Color(0.12, 0.12, 0.25, 0.85),
		Color(0.35, 0.4, 0.7)
	)
	btn_pausa.add_theme_stylebox_override("normal", estilos_pausa["normal"])
	btn_pausa.add_theme_stylebox_override("hover", estilos_pausa["hover"])
	btn_pausa.add_theme_stylebox_override("pressed", estilos_pausa["pressed"])
	btn_pausa.pressed.connect(toggle_pausa)
	btn_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	agregar_hover_sonido_juego(btn_pausa)
	capa_ui.add_child(btn_pausa)
	
	# Agregar ícono de pausa pixel art
	var icono_pausa = IconoPixel.crear("pausa", 28.0)
	icono_pausa.position = Vector2(8, 8)
	btn_pausa.add_child(icono_pausa)

func _on_pausa_continuar():
	juego_pausado = false
	panel_pausa.hide()
	get_tree().paused = false

func _on_pausa_reiniciar():
	juego_pausado = false
	panel_pausa.hide()
	get_tree().paused = false
	# Reiniciar con la misma categoría
	get_tree().change_scene_to_file("res://juego_principal.tscn")

func _on_pausa_menu():
	juego_pausado = false
	get_tree().paused = false
	Global.reproducir_transicion(snd_retirar_fichas)
	Global.abrir_categorias = false
	get_tree().change_scene_to_file("res://menu_principal.tscn")

func toggle_pausa():
	if juego_terminado:
		return
	
	juego_pausado = !juego_pausado
	
	if juego_pausado:
		panel_pausa.show()
		get_tree().paused = true
	else:
		panel_pausa.hide()
		get_tree().paused = false

# ====== PANTALLA COMPLETA ======
func _on_toggle_fullscreen():
	var modo_actual = DisplayServer.window_get_mode()
	var es_full = (modo_actual == DisplayServer.WINDOW_MODE_FULLSCREEN or modo_actual == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	if es_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Actualizar el dibujo del icono (invertimos 'es_full' porque acabamos de cambiar el estado)
	var icono = get_node_or_null("BotonFullscreen/IconoFS")
	if icono:
		icono.actualizar_estado(!es_full)
