class_name CustomCategoryView
extends RefCounted

const TemaPixel = preload("res://efectos/tema_pixel.gd")

var root: Control
var panel_editor = null
var panel_lista = null
var btn_exportar = null
var label_modo = null
var categoria_editando = ""
var btn_agregar = null
var indice_editando_pregunta = -1

# Editor
var input_nombre_cat = null
var input_pregunta = null
var inputs_opciones = []
var selector_correcta = null
var label_contador = null
var label_estado = null
var btn_guardar = null
var scroll_preguntas = null
var vbox_preguntas = null

var preguntas_temporales = []

func configurar(_root: Control):
	root = _root

func aplicar_boton(boton, col_fondo, col_borde, tam: int = 11):
	var estilos = TemaPixel.crear_boton_pixel(col_fondo, col_borde)
	boton.add_theme_stylebox_override("normal", estilos["normal"])
	boton.add_theme_stylebox_override("hover", estilos["hover"])
	boton.add_theme_stylebox_override("pressed", estilos["pressed"])
	boton.add_theme_color_override("font_color", Color(1, 1, 1))
	boton.add_theme_color_override("font_hover_color", Color(1, 1, 0.7))
	TemaPixel.aplicar_fuente_boton(boton, tam)

func crear_estilo_input() -> StyleBoxFlat:
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.02, 0.02, 0.08)
	estilo.border_width_left = 2
	estilo.border_width_right = 2
	estilo.border_width_top = 2
	estilo.border_width_bottom = 2
	estilo.border_color = Color(0.3, 0.5, 0.9)
	return estilo

func crear_panel_editor(cb_agregar, cb_guardar, cb_importar, cb_exportar, cb_volver, _cb_eliminar_pregunta, cb_hover):
	panel_editor = Control.new()
	panel_editor.name = "PanelEditorCat"
	panel_editor.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_editor.hide()
	root.add_child(panel_editor)
	panel_editor.mouse_filter = Control.MOUSE_FILTER_STOP
	panel_editor.z_index = 300
	
	var fondo = ColorRect.new()
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.color = Color(0, 0, 0, 0.97)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	panel_editor.add_child(fondo)
	
	# Panel izquierdo: formulario
	var panel_izq = Panel.new()
	panel_izq.position = Vector2(20, 20)
	panel_izq.size = Vector2(540, 608)
	panel_izq.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.05, 0.05, 0.16, 0.97), Color(0.2, 0.4, 0.85)
	))
	panel_editor.add_child(panel_izq)
	
	var titulo = Label.new()
	titulo.text = "CREAR CATEGORIA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(0, 10)
	titulo.size = Vector2(540, 30)
	TemaPixel.aplicar_fuente_label(titulo, 16)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.1))
	panel_izq.add_child(titulo)
	
	label_modo = Label.new()
	label_modo.text = "Modo: Nueva categoria"
	label_modo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_modo.position = Vector2(0, 36)
	label_modo.size = Vector2(540, 20)
	TemaPixel.aplicar_fuente_label(label_modo, 8)
	label_modo.add_theme_color_override("font_color", Color(0.5, 0.8, 1))
	panel_izq.add_child(label_modo)
	
	# Nombre categoría
	var lbl_nombre = Label.new()
	lbl_nombre.text = "Nombre de la categoria:"
	lbl_nombre.position = Vector2(20, 48)
	lbl_nombre.size = Vector2(500, 20)
	TemaPixel.aplicar_fuente_label(lbl_nombre, 9)
	lbl_nombre.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	panel_izq.add_child(lbl_nombre)
	
	input_nombre_cat = LineEdit.new()
	input_nombre_cat.placeholder_text = "Ej: Matematicas"
	input_nombre_cat.position = Vector2(20, 68)
	input_nombre_cat.size = Vector2(500, 35)
	input_nombre_cat.add_theme_stylebox_override("normal", crear_estilo_input())
	input_nombre_cat.add_theme_stylebox_override("focus", crear_estilo_input())
	input_nombre_cat.add_theme_color_override("font_color", Color(1, 1, 1))
	panel_izq.add_child(input_nombre_cat)
	
	# Pregunta
	var lbl_preg = Label.new()
	lbl_preg.text = "Pregunta:"
	lbl_preg.position = Vector2(20, 112)
	lbl_preg.size = Vector2(500, 20)
	TemaPixel.aplicar_fuente_label(lbl_preg, 9)
	lbl_preg.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	panel_izq.add_child(lbl_preg)
	
	input_pregunta = LineEdit.new()
	input_pregunta.placeholder_text = "Escribe la pregunta aqui"
	input_pregunta.position = Vector2(20, 132)
	input_pregunta.size = Vector2(500, 35)
	input_pregunta.add_theme_stylebox_override("normal", crear_estilo_input())
	input_pregunta.add_theme_stylebox_override("focus", crear_estilo_input())
	input_pregunta.add_theme_color_override("font_color", Color(1, 1, 1))
	panel_izq.add_child(input_pregunta)
	
	# 4 opciones
	inputs_opciones.clear()
	var letras = ["A", "B", "C", "D"]
	for i in range(4):
		var lbl_op = Label.new()
		lbl_op.text = "Opcion " + letras[i] + ":"
		lbl_op.position = Vector2(20, 178 + i * 55)
		lbl_op.size = Vector2(500, 20)
		TemaPixel.aplicar_fuente_label(lbl_op, 8)
		lbl_op.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		panel_izq.add_child(lbl_op)
		
		var inp = LineEdit.new()
		inp.placeholder_text = "Opcion " + letras[i]
		inp.position = Vector2(20, 196 + i * 55)
		inp.size = Vector2(500, 32)
		inp.add_theme_stylebox_override("normal", crear_estilo_input())
		inp.add_theme_stylebox_override("focus", crear_estilo_input())
		inp.add_theme_color_override("font_color", Color(1, 1, 1))
		panel_izq.add_child(inp)
		inputs_opciones.append(inp)
	
	# Selector respuesta correcta
	var lbl_correcta = Label.new()
	lbl_correcta.text = "Respuesta correcta:"
	lbl_correcta.position = Vector2(20, 420)
	lbl_correcta.size = Vector2(200, 20)
	TemaPixel.aplicar_fuente_label(lbl_correcta, 9)
	lbl_correcta.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
	panel_izq.add_child(lbl_correcta)
	
	selector_correcta = OptionButton.new()
	selector_correcta.position = Vector2(220, 415)
	selector_correcta.size = Vector2(300, 30)
	selector_correcta.add_item("A (primera opcion)", 0)
	selector_correcta.add_item("B (segunda opcion)", 1)
	selector_correcta.add_item("C (tercera opcion)", 2)
	selector_correcta.add_item("D (cuarta opcion)", 3)
	panel_izq.add_child(selector_correcta)
	
	# Botón agregar
	btn_agregar = Button.new()
	btn_agregar.text = "+ AGREGAR PREGUNTA"
	btn_agregar.position = Vector2(20, 460)
	btn_agregar.size = Vector2(500, 45)
	aplicar_boton(btn_agregar, Color(0.06, 0.35, 0.12), Color(0.15, 0.8, 0.3), 12)
	btn_agregar.pressed.connect(cb_agregar)
	btn_agregar.mouse_entered.connect(cb_hover)
	panel_izq.add_child(btn_agregar)
	
	# Estado y contador
	label_contador = Label.new()
	label_contador.text = "Preguntas: 0/42"
	label_contador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_contador.position = Vector2(0, 515)
	label_contador.size = Vector2(540, 20)
	TemaPixel.aplicar_fuente_label(label_contador, 10)
	label_contador.add_theme_color_override("font_color", Color(1, 0.5, 0.3))
	panel_izq.add_child(label_contador)
	
	label_estado = Label.new()
	label_estado.text = ""
	label_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_estado.position = Vector2(0, 538)
	label_estado.size = Vector2(540, 20)
	TemaPixel.aplicar_fuente_label(label_estado, 8)
	label_estado.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	panel_izq.add_child(label_estado)
	
	# Botones inferiores
	btn_guardar = Button.new()
	btn_guardar.text = "GUARDAR"
	btn_guardar.position = Vector2(20, 560)
	btn_guardar.size = Vector2(160, 38)
	aplicar_boton(btn_guardar, Color(0.1, 0.3, 0.5), Color(0.3, 0.7, 1), 10)
	btn_guardar.pressed.connect(cb_guardar)
	btn_guardar.mouse_entered.connect(cb_hover)
	btn_guardar.disabled = true
	panel_izq.add_child(btn_guardar)
	
	var btn_importar = Button.new()
	btn_importar.text = "IMPORTAR"
	btn_importar.position = Vector2(190, 560)
	btn_importar.size = Vector2(160, 38)
	btn_importar.tooltip_text = "Carga un archivo .json con preguntas desde tu computadora.\nEl archivo debe seguir el mismo formato de la plantilla."
	aplicar_boton(btn_importar, Color(0.3, 0.2, 0.1), Color(0.7, 0.5, 0.2), 10)
	btn_importar.pressed.connect(cb_importar)
	btn_importar.mouse_entered.connect(cb_hover)
	panel_izq.add_child(btn_importar)
	
	btn_exportar = Button.new()
	btn_exportar.text = "PLANTILLA"
	btn_exportar.position = Vector2(360, 560)
	btn_exportar.size = Vector2(160, 38)
	btn_exportar.tooltip_text = "Exporta un archivo .json de ejemplo a tu computadora.\nPuedes editarlo en cualquier editor de texto para crear\ntus preguntas masivamente y luego importarlo."
	aplicar_boton(btn_exportar, Color(0.15, 0.15, 0.35), Color(0.4, 0.5, 0.9), 10)
	btn_exportar.pressed.connect(cb_exportar)
	btn_exportar.mouse_entered.connect(cb_hover)
	panel_izq.add_child(btn_exportar)
	
	# Panel derecho: lista de preguntas
	var panel_der = Panel.new()
	panel_der.position = Vector2(575, 20)
	panel_der.size = Vector2(557, 608)
	panel_der.add_theme_stylebox_override("panel", TemaPixel.crear_panel_pixel(
		Color(0.05, 0.05, 0.16, 0.97), Color(0.2, 0.4, 0.85)
	))
	panel_editor.add_child(panel_der)
	
	var titulo_lista = Label.new()
	titulo_lista.text = "PREGUNTAS AGREGADAS"
	titulo_lista.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo_lista.position = Vector2(0, 10)
	titulo_lista.size = Vector2(557, 30)
	TemaPixel.aplicar_fuente_label(titulo_lista, 12)
	titulo_lista.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
	panel_der.add_child(titulo_lista)
	
	scroll_preguntas = ScrollContainer.new()
	scroll_preguntas.position = Vector2(10, 45)
	scroll_preguntas.size = Vector2(537, 510)
	panel_der.add_child(scroll_preguntas)
	
	vbox_preguntas = VBoxContainer.new()
	vbox_preguntas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_preguntas.add_child(vbox_preguntas)
	
	var btn_volver = Button.new()
	btn_volver.text = "< VOLVER"
	btn_volver.position = Vector2(200, 565)
	btn_volver.size = Vector2(150, 35)
	aplicar_boton(btn_volver, Color(0.35, 0.1, 0.1), Color(0.8, 0.3, 0.3), 10)
	btn_volver.pressed.connect(cb_volver)
	btn_volver.mouse_entered.connect(cb_hover)
	panel_der.add_child(btn_volver)

func obtener_datos_formulario() -> Dictionary:
	var pregunta_texto = input_pregunta.text.strip_edges()
	var opciones = []
	for inp in inputs_opciones:
		opciones.append(inp.text.strip_edges())
	var correcta = selector_correcta.selected
	return {
		"pregunta": pregunta_texto,
		"opciones": opciones,
		"correcta": correcta
	}

func obtener_nombre_categoria() -> String:
	return input_nombre_cat.text.strip_edges()

func limpiar_formulario():
	input_pregunta.text = ""
	for inp in inputs_opciones:
		inp.text = ""
	selector_correcta.selected = 0

func actualizar_contador(cantidad: int):
	label_contador.text = "Preguntas: " + str(cantidad) + "/42"
	if cantidad >= 42:
		label_contador.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
		btn_guardar.disabled = false
	else:
		label_contador.add_theme_color_override("font_color", Color(1, 0.5, 0.3))
		btn_guardar.disabled = true

func mostrar_estado(texto: String, color: Color = Color(0.5, 0.8, 0.5)):
	label_estado.text = texto
	label_estado.add_theme_color_override("font_color", color)

func agregar_pregunta_a_lista(indice: int, texto_pregunta: String, cb_editar: Callable, cb_eliminar: Callable, cb_hover: Callable):
	var hbox = HBoxContainer.new()
	hbox.name = "Pregunta_" + str(indice)
	
	var lbl = Label.new()
	lbl.text = str(indice + 1) + ". " + texto_pregunta
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	TemaPixel.aplicar_fuente_label(lbl, 8)
	lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	hbox.add_child(lbl)
	
	var btn_edit = Button.new()
	btn_edit.text = "E"
	btn_edit.custom_minimum_size = Vector2(30, 25)
	aplicar_boton(btn_edit, Color(0.1, 0.2, 0.35), Color(0.3, 0.6, 1), 8)
	btn_edit.pressed.connect(cb_editar.bind(indice))
	btn_edit.mouse_entered.connect(cb_hover)
	hbox.add_child(btn_edit)
	
	var btn_del = Button.new()
	btn_del.text = "X"
	btn_del.custom_minimum_size = Vector2(30, 25)
	aplicar_boton(btn_del, Color(0.35, 0.06, 0.06), Color(0.8, 0.2, 0.2), 8)
	btn_del.pressed.connect(cb_eliminar.bind(indice))
	btn_del.mouse_entered.connect(cb_hover)
	hbox.add_child(btn_del)
	
	vbox_preguntas.add_child(hbox)

func reconstruir_lista(preguntas: Array, cb_editar: Callable, cb_eliminar: Callable, cb_hover: Callable):
	for child in vbox_preguntas.get_children():
		child.queue_free()
	for i in range(preguntas.size()):
		agregar_pregunta_a_lista(i, preguntas[i]["pregunta"], cb_editar, cb_eliminar, cb_hover)

func establecer_modo_nueva():
	categoria_editando = ""
	if label_modo:
		label_modo.text = "Modo: Nueva categoria"

func establecer_modo_edicion(nombre: String):
	categoria_editando = nombre
	if label_modo:
		label_modo.text = "Editando: " + nombre

func cargar_categoria_en_editor(nombre: String, preguntas: Array, cb_editar: Callable, cb_eliminar: Callable, cb_hover: Callable):
	input_nombre_cat.text = nombre
	reconstruir_lista(preguntas, cb_editar, cb_eliminar, cb_hover)
	actualizar_contador(preguntas.size())
	establecer_modo_edicion(nombre)
	mostrar_estado("Categoria cargada para editar", Color(0.3, 0.8, 1))

func obtener_categoria_editando() -> String:
	return categoria_editando

func resetear_editor():
	indice_editando_pregunta = -1
	if btn_agregar:
		btn_agregar.text = "+ AGREGAR PREGUNTA"
	preguntas_temporales.clear()
	limpiar_formulario()
	input_nombre_cat.text = ""
	categoria_editando = ""
	if label_modo:
		label_modo.text = "Modo: Nueva categoria"
	actualizar_contador(0)
	mostrar_estado("")
	for child in vbox_preguntas.get_children():
		child.queue_free()

func cargar_pregunta_en_formulario(pregunta: Dictionary, indice: int):
	indice_editando_pregunta = indice
	input_pregunta.text = pregunta.get("pregunta", "")
	
	var opciones = pregunta.get("opciones", [])
	for i in range(4):
		if i < opciones.size():
			inputs_opciones[i].text = str(opciones[i])
		else:
			inputs_opciones[i].text = ""
	
	selector_correcta.selected = int(pregunta.get("correcta", 0))
	
	if btn_agregar:
		btn_agregar.text = "GUARDAR CAMBIOS"
	
	mostrar_estado("Editando pregunta " + str(indice + 1), Color(0.3, 0.8, 1))

func salir_modo_edicion_pregunta():
	indice_editando_pregunta = -1
	limpiar_formulario()
	if btn_agregar:
		btn_agregar.text = "+ AGREGAR PREGUNTA"

func esta_editando_pregunta() -> bool:
	return indice_editando_pregunta >= 0

func obtener_indice_editando_pregunta() -> int:
	return indice_editando_pregunta
