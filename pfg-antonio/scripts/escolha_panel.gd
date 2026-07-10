extends Panel

@onready var inspecao = $"../InspecaoDiario"

func _ready():
	visible = false

func _on_botao_capa_pressed():

	visible = false
	inspecao.visible = true

	EstadoJogo.registrar_progresso("diario", "olhou")


func _on_botao_privacidade_pressed():

	visible = false

	var cama = get_tree().get_first_node_in_group("cama")

	if cama:
		cama.resetar()

	inspecao.visible = false

	EstadoJogo.registrar_progresso("diario", "respeitou")

	EstadoJogo.ui_aberta = false
