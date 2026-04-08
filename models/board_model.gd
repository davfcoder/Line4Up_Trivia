class_name BoardModel
extends RefCounted

const COLUMNAS := 7
const FILAS := 6

var matriz_tablero := []
var columnas_congeladas_info := []
var fichas_ganadoras := []

func _init():
	crear_matriz_tablero()

func crear_matriz_tablero():
	matriz_tablero.clear()
	for x in range(COLUMNAS):
		var columna := []
		for y in range(FILAS):
			columna.append(0)
		matriz_tablero.append(columna)

func reiniciar():
	crear_matriz_tablero()
	columnas_congeladas_info.clear()
	fichas_ganadoras.clear()

func buscar_fila_disponible(columna: int) -> int:
	for y in range(FILAS - 1, -1, -1):
		if matriz_tablero[columna][y] == 0:
			return y
	return -1

func esta_columna_congelada(columna: int) -> bool:
	for info in columnas_congeladas_info:
		if info["columna"] == columna:
			return true
	return false

func tablero_lleno() -> bool:
	for x in range(COLUMNAS):
		if matriz_tablero[x][0] == 0:
			return false
	return true

func colocar_ficha(columna: int, jugador: int) -> int:
	if esta_columna_congelada(columna):
		return -1
	
	var fila := buscar_fila_disponible(columna)
	if fila == -1:
		return -1
	
	matriz_tablero[columna][fila] = jugador
	return fila

func quitar_ficha(columna: int, fila: int):
	matriz_tablero[columna][fila] = 0

func congelar_columna(columna: int, puesto_por: int):
	columnas_congeladas_info.append({
		"columna": columna,
		"puesto_por": puesto_por
	})

func descongelar_columnas_de_jugador(turno_actual: int) -> Array:
	var columnas_a_quitar := []
	
	for info in columnas_congeladas_info:
		if info["puesto_por"] == turno_actual:
			columnas_a_quitar.append(info)
	
	for info in columnas_a_quitar:
		columnas_congeladas_info.erase(info)
	
	return columnas_a_quitar

func obtener_fichas_en_direccion(col: int, fil: int, dx: int, dy: int, jugador: int) -> Array:
	var fichas := []
	var x := col + dx
	var y := fil + dy
	
	while x >= 0 and x < COLUMNAS and y >= 0 and y < FILAS:
		# Si chocamos con una columna congelada, la línea se rompe
		if esta_columna_congelada(x):
			break
		
		if matriz_tablero[x][y] == jugador:
			fichas.append(Vector2i(x, y))
			x += dx
			y += dy
		else:
			break
	
	return fichas

func verificar_victoria(columna: int, fila: int, jugador: int) -> bool:
	# Si la ficha desde la que revisamos está en columna congelada, no hay victoria
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

func verificar_victoria_completa(turno_actual: int) -> Dictionary:
	var jugadores_a_revisar = [turno_actual, 2 if turno_actual == 1 else 1]
	
	for j in jugadores_a_revisar:
		for x in range(COLUMNAS):
			for y in range(FILAS):
				if matriz_tablero[x][y] == j:
					if verificar_victoria(x, y, j):
						return {
							"hay_victoria": true,
							"ganador": j
						}
	
	return {
		"hay_victoria": false,
		"ganador": 0
	}

func obtener_dueno_celda(columna: int, fila: int) -> int:
	return matriz_tablero[columna][fila]

func esta_vacia(columna: int, fila: int) -> bool:
	return matriz_tablero[columna][fila] == 0

func usar_bomba(turno_actual: int, columna: int, fila: int) -> Dictionary:
	var enemigo = 2 if turno_actual == 1 else 1
	
	if esta_columna_congelada(columna):
		return {
			"ok": false,
			"motivo": "COLUMNA_CONGELADA"
		}
	
	if esta_vacia(columna, fila):
		return {
			"ok": false,
			"motivo": "CELDA_VACIA"
		}
	
	if matriz_tablero[columna][fila] == turno_actual:
		return {
			"ok": false,
			"motivo": "FICHA_PROPIA"
		}
	
	if matriz_tablero[columna][fila] != enemigo:
		return {
			"ok": false,
			"motivo": "NO_ES_ENEMIGA"
		}
	
	quitar_ficha(columna, fila)
	
	return {
		"ok": true,
		"motivo": "OK"
	}

func usar_hielo(turno_actual: int, columna: int) -> Dictionary:
	if esta_columna_congelada(columna):
		return {
			"ok": false,
			"motivo": "YA_CONGELADA"
		}
	
	congelar_columna(columna, turno_actual)
	
	return {
		"ok": true,
		"motivo": "OK"
	}

func aplicar_gravedad_logica(columna: int) -> Array:
	var movimientos := []
	var hubo_cambio = true
	
	while hubo_cambio:
		hubo_cambio = false
		
		for y in range(FILAS - 2, -1, -1):
			if matriz_tablero[columna][y] != 0 and matriz_tablero[columna][y + 1] == 0:
				var jugador = matriz_tablero[columna][y]
				matriz_tablero[columna][y + 1] = jugador
				matriz_tablero[columna][y] = 0
				
				movimientos.append({
					"columna": columna,
					"desde_fila": y,
					"hacia_fila": y + 1,
					"jugador": jugador
				})
				
				hubo_cambio = true
	
	return movimientos

func descongelar_columnas_de_turno(turno_actual: int) -> Array:
	return descongelar_columnas_de_jugador(turno_actual)

func obtener_posiciones_enemigas(turno_actual: int) -> Array:
	var enemigo = 2 if turno_actual == 1 else 1
	var posiciones = []
	for x in range(COLUMNAS):
		if esta_columna_congelada(x):
			continue
		for y in range(FILAS):
			if matriz_tablero[x][y] == enemigo:
				posiciones.append(Vector2i(x, y))
	return posiciones
