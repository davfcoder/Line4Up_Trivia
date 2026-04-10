class_name CustomCategoryModel
extends RefCounted

const RUTA_GUARDADO = "user://categorias_personalizadas/"
const MIN_PREGUNTAS = 42

static func asegurar_directorio() -> void:
	var dir = DirAccess.open("user://")
	if dir == null:
		return
	if not dir.dir_exists("categorias_personalizadas"):
		dir.make_dir("categorias_personalizadas")

static func obtener_categorias_guardadas() -> Array:
	asegurar_directorio()
	var categorias = []
	var dir_cat = DirAccess.open(RUTA_GUARDADO)
	if dir_cat == null:
		return categorias
	
	dir_cat.list_dir_begin()
	var nombre = dir_cat.get_next()
	while nombre != "":
		if not dir_cat.current_is_dir() and nombre.ends_with(".json"):
			categorias.append(nombre.replace(".json", ""))
		nombre = dir_cat.get_next()
	dir_cat.list_dir_end()
	categorias.sort()
	return categorias

static func existe_categoria(nombre: String) -> bool:
	if nombre.strip_edges() == "":
		return false
	asegurar_directorio()
	var ruta = RUTA_GUARDADO + nombre + ".json"
	return FileAccess.file_exists(ruta)

static func nombre_valido(nombre: String) -> bool:
	var limpio = nombre.strip_edges()
	if limpio == "":
		return false
	
	var invalidos = ["/", "\\", ":", "*", "?", "\"", "<", ">", "|"]
	for c in invalidos:
		if limpio.contains(c):
			return false
	
	return true

static func cargar_categoria(nombre: String) -> Array:
	var ruta = RUTA_GUARDADO + nombre + ".json"
	var archivo = FileAccess.open(ruta, FileAccess.READ)
	if archivo == null:
		return []
	var contenido = archivo.get_as_text()
	archivo.close()
	
	var json = JSON.new()
	if json.parse(contenido) != OK:
		return []
	
	if json.data is Array:
		return json.data
	
	return []

static func guardar_categoria(nombre: String, preguntas: Array, sobrescribir: bool = false) -> Dictionary:
	asegurar_directorio()
	nombre = nombre.strip_edges()
	
	if not nombre_valido(nombre):
		return {"ok": false, "motivo": "Nombre invalido para la categoria"}
	
	if preguntas.size() < MIN_PREGUNTAS:
		return {"ok": false, "motivo": "Necesitas minimo " + str(MIN_PREGUNTAS) + " preguntas"}
	
	if existe_categoria(nombre) and not sobrescribir:
		return {"ok": false, "motivo": "Ya existe una categoria con ese nombre"}
	
	var ruta = RUTA_GUARDADO + nombre + ".json"
	var archivo = FileAccess.open(ruta, FileAccess.WRITE)
	if archivo == null:
		return {"ok": false, "motivo": "No se pudo guardar el archivo"}
	
	archivo.store_string(JSON.stringify(preguntas, "\t"))
	archivo.close()
	return {"ok": true}

static func eliminar_categoria(nombre: String) -> bool:
	asegurar_directorio()
	var ruta = RUTA_GUARDADO + nombre + ".json"
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ruta)
		return true
	return false

static func renombrar_categoria(nombre_actual: String, nuevo_nombre: String) -> Dictionary:
	asegurar_directorio()
	nombre_actual = nombre_actual.strip_edges()
	nuevo_nombre = nuevo_nombre.strip_edges()
	
	if not existe_categoria(nombre_actual):
		return {"ok": false, "motivo": "La categoria original no existe"}
	
	if not nombre_valido(nuevo_nombre):
		return {"ok": false, "motivo": "El nuevo nombre no es valido"}
	
	if nombre_actual != nuevo_nombre and existe_categoria(nuevo_nombre):
		return {"ok": false, "motivo": "Ya existe una categoria con ese nombre"}
	
	var ruta_origen = RUTA_GUARDADO + nombre_actual + ".json"
	var ruta_destino = RUTA_GUARDADO + nuevo_nombre + ".json"
	
	var err = DirAccess.rename_absolute(ruta_origen, ruta_destino)
	if err != OK:
		return {"ok": false, "motivo": "No se pudo renombrar la categoria"}
	
	return {"ok": true}

static func validar_preguntas(datos: Array) -> Dictionary:
	if datos.is_empty():
		return {"ok": false, "motivo": "El archivo no contiene preguntas"}
	
	for i in range(datos.size()):
		var p = datos[i]
		
		if not p is Dictionary:
			return {"ok": false, "motivo": "Elemento " + str(i + 1) + " no es una pregunta valida"}
		
		if not p.has("pregunta") or not p.has("opciones") or not p.has("correcta"):
			return {"ok": false, "motivo": "Pregunta " + str(i + 1) + " incompleta"}
		
		if not p["pregunta"] is String or p["pregunta"].strip_edges() == "":
			return {"ok": false, "motivo": "Pregunta " + str(i + 1) + " vacia"}
		
		if not p["opciones"] is Array or p["opciones"].size() != 4:
			return {"ok": false, "motivo": "Pregunta " + str(i + 1) + " debe tener 4 opciones"}
		
		for j in range(4):
			if not p["opciones"][j] is String or p["opciones"][j].strip_edges() == "":
				return {"ok": false, "motivo": "Pregunta " + str(i + 1) + ": opcion " + str(j + 1) + " vacia"}
		
		if not p["correcta"] is int and not p["correcta"] is float:
			return {"ok": false, "motivo": "Pregunta " + str(i + 1) + ": 'correcta' debe ser numero 0-3"}
		
		var correcta = int(p["correcta"])
		if correcta < 0 or correcta > 3:
			return {"ok": false, "motivo": "Pregunta " + str(i + 1) + ": 'correcta' debe ser 0, 1, 2 o 3"}
	
	return {"ok": true}

static func importar_desde_archivo(ruta_origen: String) -> Dictionary:
	var archivo = FileAccess.open(ruta_origen, FileAccess.READ)
	if archivo == null:
		return {"ok": false, "motivo": "No se pudo abrir el archivo"}
	
	var contenido = archivo.get_as_text()
	archivo.close()
	
	var json = JSON.new()
	if json.parse(contenido) != OK:
		return {"ok": false, "motivo": "El archivo no es JSON valido"}
	
	var datos = json.data
	if not datos is Array:
		return {"ok": false, "motivo": "El formato debe ser una lista de preguntas"}
	
	var validacion = validar_preguntas(datos)
	if not validacion["ok"]:
		return validacion
	
	return {
		"ok": true,
		"preguntas": datos,
		"cantidad": datos.size()
	}

static func crear_plantilla_json() -> String:
	var ejemplo = [
		{
			"pregunta": "Escribe aqui tu pregunta 1",
			"opciones": ["Opcion A", "Opcion B", "Opcion C", "Opcion D"],
			"correcta": 0
		},
		{
			"pregunta": "Escribe aqui tu pregunta 2",
			"opciones": ["Opcion A", "Opcion B", "Opcion C", "Opcion D"],
			"correcta": 1
		}
	]
	return JSON.stringify(ejemplo, "\t")

static func exportar_plantilla(ruta_destino: String) -> Dictionary:
	var archivo = FileAccess.open(ruta_destino, FileAccess.WRITE)
	if archivo == null:
		return {"ok": false, "motivo": "No se pudo crear la plantilla"}
	
	archivo.store_string(crear_plantilla_json())
	archivo.close()
	return {"ok": true}
