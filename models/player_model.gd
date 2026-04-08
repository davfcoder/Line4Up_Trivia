class_name PlayerModel
extends RefCounted

var id: int = 1
var racha: int = 0
var bombas: int = 0
var hielos: int = 0

func _init(player_id: int = 1):
	id = player_id

func registrar_acierto():
	racha += 1

func registrar_fallo():
	racha = 0

func reiniciar_racha():
	racha = 0

func tiene_racha_para_poder() -> bool:
	return racha >= 2

func consumir_racha_poder():
	racha = 0

func otorgar_poder(poder: String):
	match poder:
		"BOMBA":
			bombas += 1
		"HIELO":
			hielos += 1

func tiene_bombas() -> bool:
	return bombas > 0

func tiene_hielos() -> bool:
	return hielos > 0

func usar_bomba() -> bool:
	if bombas <= 0:
		return false
	bombas -= 1
	return true

func usar_hielo() -> bool:
	if hielos <= 0:
		return false
	hielos -= 1
	return true
