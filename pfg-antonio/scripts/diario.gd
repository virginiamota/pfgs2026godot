extends Area2D

var encontrado = false


func _ready():

	visible = false
	input_pickable = false


func _input_event(viewport, event, shape_idx):

	if EstadoJogo.ui_aberta:
		return

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:

				interagir()


func interagir():

	if encontrado:
		return

	encontrado = true

	print("Diário encontrado")

	mostrar_popup()


func mostrar_popup():

	var painel = get_tree().get_first_node_in_group("escolha_panel")

	if painel:
		painel.visible = true
		EstadoJogo.ui_aberta = true
