class_name TriviaModel
extends RefCounted

var preguntas_base = []
var preguntas_activas = []
var pregunta_actual = {}

func cargar_preguntas_desde_json(ruta: String, categoria: String):
	var archivo = FileAccess.open(ruta, FileAccess.READ)
	if archivo == null:
		print("ERROR: No se pudo abrir preguntas.json")
		preguntas_base = [
			{
				"pregunta": "Pregunta de emergencia: ¿Capital de Colombia?",
				"opciones": ["Medellín", "Bogotá", "Cali", "Cartagena"],
				"correcta": 1
			}
		]
		preguntas_activas = preguntas_base.duplicate(true)
		return
	
	var contenido = archivo.get_as_text()
	archivo.close()
	
	var json = JSON.new()
	var resultado = json.parse(contenido)
	
	if resultado != OK:
		print("ERROR: JSON mal formateado")
		preguntas_base = []
		preguntas_activas = []
		return
	
	var datos = json.data
	
	if datos.has(categoria):
		preguntas_base = datos[categoria]
		preguntas_activas = preguntas_base.duplicate(true)
		print("Cargadas ", preguntas_base.size(), " preguntas - Categoría: ", categoria)
	else:
		print("ERROR: Categoría '", categoria, "' no encontrada en JSON")
		preguntas_base = []
		preguntas_activas = []

func reiniciar_preguntas():
	preguntas_activas = preguntas_base.duplicate(true)

func obtener_pregunta_aleatoria() -> Dictionary:
	if preguntas_activas.size() == 0:
		reiniciar_preguntas()
	
	if preguntas_activas.size() == 0:
		pregunta_actual = {}
		return {}
	
	var indice = randi() % preguntas_activas.size()
	pregunta_actual = preguntas_activas[indice].duplicate(true)
	preguntas_activas.remove_at(indice)
	
	var texto_respuesta_correcta = pregunta_actual["opciones"][pregunta_actual["correcta"]]
	var opciones_mezcladas = pregunta_actual["opciones"].duplicate()
	opciones_mezcladas.shuffle()
	pregunta_actual["opciones"] = opciones_mezcladas
	pregunta_actual["correcta"] = opciones_mezcladas.find(texto_respuesta_correcta)
	
	return pregunta_actual

func establecer_pregunta_actual(pregunta: Dictionary):
	pregunta_actual = pregunta.duplicate(true)

func es_respuesta_correcta(indice_boton: int) -> bool:
	if pregunta_actual.is_empty():
		return false
	return indice_boton == pregunta_actual["correcta"]

func obtener_respuesta_correcta_texto() -> String:
	if pregunta_actual.is_empty():
		return ""
	return pregunta_actual["opciones"][pregunta_actual["correcta"]]
