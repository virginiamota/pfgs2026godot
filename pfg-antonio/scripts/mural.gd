extends Area2D

func _input_event(viewport, event, shape_idx):

	if EstadoJogo.ui_aberta:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		abrir_mural()

func abrir_mural():

	EstadoJogo.ui_aberta = true

	var inspecao = get_tree().get_first_node_in_group("inspecao_mural")

	if inspecao:
		inspecao.abrir()
