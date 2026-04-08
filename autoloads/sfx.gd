extends Node

# Fichas por fila
var ficha = {
	5: preload("res://sonidos/fichaf1.wav"),
	4: preload("res://sonidos/fichaf2.wav"),
	3: preload("res://sonidos/fichaf3.wav"),
	2: preload("res://sonidos/fichaf4.wav"),
	1: preload("res://sonidos/fichaf5.wav"),
	0: preload("res://sonidos/fichaf6.wav")
}

var bomba_seleccionada = preload("res://sonidos/bomba_seleccionada.wav")
var hielo_seleccionado = preload("res://sonidos/hielo_seleccionado.wav")
var congelado = preload("res://sonidos/congelado.wav")
var explosion = preload("res://sonidos/explosion.wav")
var retirar_fichas = preload("res://sonidos/retirar_todas_fichas.wav")
var ficha_seleccionada = preload("res://sonidos/ficha_seleccionada.wav")
var victoria = preload("res://sonidos/clapping.wav")
var empate = preload("res://sonidos/draw.wav")
var tick = preload("res://sonidos/tick.wav")
var correcto = preload("res://sonidos/correcto.wav")
var incorrecto = preload("res://sonidos/incorrecto.wav")
var hover = preload("res://sonidos/hover1.wav")
