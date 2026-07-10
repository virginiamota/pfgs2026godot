extends Control

@onready var ursinho_gaveta = $ObjetosGaveta/UrsinhoGaveta
@onready var desenho_rabiscado = $ObjetosGaveta/DesenhoRabiscado
@onready var pasta_escolar = $ObjetosGaveta/PastaEscolar

func _ready():

	visible = false

	EstadoJogo.ursinho_mudou.connect(atualizar_objetos)
	EstadoJogo.desenho_mudou.connect(atualizar_objetos)

func abrir():

	visible = true

	atualizar_objetos()

func atualizar_objetos():

	var mesa = get_tree().get_first_node_in_group("mesa")

	var gaveta = 0

	if mesa:
		gaveta = mesa.gaveta_aberta

	var estado = EstadoJogo.ursinho_estado

	ursinho_gaveta.visible = gaveta == 2 and (estado == EstadoJogo.Ursinho.NA_GAVETA or estado == EstadoJogo.Ursinho.DEVOLVIDO)

	desenho_rabiscado.visible = gaveta == 1 and EstadoJogo.desenho_estado != EstadoJogo.Desenho.NO_INVENTARIO

	desenho_rabiscado.resetar_posicao()

	pasta_escolar.visible = gaveta == 1

func _on_botao_voltar_pressed():

	fechar_inspecao()

func _on_ursinho_gaveta_gui_input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pegar_ursinho()

func pegar_ursinho():

	EstadoJogo.mudar_ursinho(EstadoJogo.Ursinho.SEGURANDO)

func fechar_inspecao():

	visible = false

	var mesa = get_tree().get_first_node_in_group("mesa")

	if mesa:
		mesa.fechar()

	EstadoJogo.ui_aberta = false

func _on_pasta_escolar_gui_input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		var inspecao_pasta = get_tree().get_first_node_in_group("inspecao_pasta")

		if inspecao_pasta:
			inspecao_pasta.abrir()
