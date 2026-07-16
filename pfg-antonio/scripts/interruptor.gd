extends Area2D

@onready var luz = $"../../Luz"
@onready var som = $Som

var ligado = true

func _input_event(viewport, event, shape_idx):

	if EstadoJogo.ui_aberta:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		alternar()

func alternar():

	ligado = not ligado

	som.play()

	if ligado:
		luz.color = Color(1, 1, 1)
		Acessibilidade.legenda("[luz acende]")
	else:
		luz.color = Color(0.5, 0.5, 0.58)
		Acessibilidade.legenda("[luz apaga]")
