extends Panel

@onready var inspecao = $"../InspecaoGaveta"

func _ready():
	visible = false

func _on_botao_olhar_pressed():

	visible = false
	inspecao.abrir()


func _on_botao_fechar_pressed():

	visible = false

	var mesa = get_tree().get_first_node_in_group("mesa")

	if mesa:
		mesa.fechar()

	EstadoJogo.ui_aberta = false
