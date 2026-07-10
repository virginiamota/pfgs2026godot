extends Control

func _ready():
	visible = false

func _on_botao_voltar_pressed():

	visible = false

	var cama = get_tree().get_first_node_in_group("cama")

	if cama:
		cama.resetar()

	EstadoJogo.ui_aberta = false
