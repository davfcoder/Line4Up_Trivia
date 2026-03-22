extends Node

var modo_juego = "1v1"
var musica_activa = true
var categoria = "ingles"
var abrir_categorias = false

const TemaPixel = preload("res://efectos/tema_pixel.gd")
const IconoPixel = preload("res://efectos/icono_pixel.gd")

var _sonido_transicion: AudioStreamPlayer

func _ready():
	_sonido_transicion = AudioStreamPlayer.new()
	_sonido_transicion.volume_db = -5
	add_child(_sonido_transicion)

func reproducir_transicion(sonido):
	_sonido_transicion.stream = sonido
	_sonido_transicion.play()

func crear_boton_musica(padre, callback):
	var btn = Button.new()
	btn.name = "BotonMusica"
	btn.text = ""
	btn.position = Vector2(10, 10)
	btn.size = Vector2(45, 45)
	btn.z_index = 50
	
	var estilos = TemaPixel.crear_boton_pixel(
		Color(0.08, 0.25, 0.12, 0.9),
		Color(0.25, 0.7, 0.35)
	)
	btn.add_theme_stylebox_override("normal", estilos["normal"])
	btn.add_theme_stylebox_override("hover", estilos["hover"])
	btn.add_theme_stylebox_override("pressed", estilos["pressed"])
	btn.pressed.connect(callback)
	padre.add_child(btn)
	
	var tipo_icono = "sonido_on" if musica_activa else "sonido_off"
	var icono = IconoPixel.crear(tipo_icono, 28.0)
	icono.name = "IconoMusica"
	icono.position = Vector2(8, 8)
	btn.add_child(icono)
	return btn

func actualizar_boton_musica(btn):
	if btn:
		var icono = btn.get_node_or_null("IconoMusica")
		if icono:
			icono.tipo = "sonido_on" if musica_activa else "sonido_off"
			icono.queue_redraw()
		if musica_activa:
			var e = TemaPixel.crear_boton_pixel(Color(0.08, 0.25, 0.12, 0.9), Color(0.25, 0.7, 0.35))
			btn.add_theme_stylebox_override("normal", e["normal"])
			btn.add_theme_stylebox_override("hover", e["hover"])
		else:
			var e = TemaPixel.crear_boton_pixel(Color(0.25, 0.08, 0.08, 0.9), Color(0.7, 0.25, 0.25))
			btn.add_theme_stylebox_override("normal", e["normal"])
			btn.add_theme_stylebox_override("hover", e["hover"])
