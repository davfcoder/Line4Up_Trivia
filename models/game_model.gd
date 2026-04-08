class_name GameModel
extends RefCounted

const FASE_PREGUNTA := "PREGUNTA"
const FASE_LANZAMIENTO := "LANZAMIENTO"
const FASE_ANIMANDO := "ANIMANDO"
const FASE_FIN := "FIN"

var board_model
var trivia_model
var jugador1_model
var jugador2_model

var turno_actual: int = 1
var fase_juego: String = FASE_PREGUNTA
var juego_terminado: bool = false

func _init(board, trivia, jugador1, jugador2):
	board_model = board
	trivia_model = trivia
	jugador1_model = jugador1
	jugador2_model = jugador2

func obtener_jugador_actual():
	return jugador1_model if turno_actual == 1 else jugador2_model

func obtener_jugador_rival():
	return jugador2_model if turno_actual == 1 else jugador1_model

func obtener_jugador_por_id(id_jugador: int):
	return jugador1_model if id_jugador == 1 else jugador2_model

func cambiar_turno():
	turno_actual = 2 if turno_actual == 1 else 1

func reiniciar_estado_partida():
	turno_actual = 1
	fase_juego = FASE_PREGUNTA
	juego_terminado = false
