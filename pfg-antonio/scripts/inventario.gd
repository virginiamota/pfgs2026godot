extends CanvasLayer

@onready var barra = $Barra
@onready var slot_ursinho = $Barra/Slot
@onready var icone_ursinho = $Barra/Slot/IconeUrsinho
@onready var slot_desenho = $Barra/SlotDesenho
@onready var icone_desenho = $Barra/SlotDesenho/IconeDesenho
@onready var arrasto = $Arrasto

var item_arrastado = ""

func _ready():

	arrasto.visible = false

	EstadoJogo.ursinho_mudou.connect(atualizar)
	EstadoJogo.desenho_mudou.connect(atualizar)

	atualizar()

func atualizar():

	slot_ursinho.visible = EstadoJogo.ursinho_estado == EstadoJogo.Ursinho.SEGURANDO

	icone_ursinho.visible = slot_ursinho.visible and item_arrastado != "ursinho"

	slot_desenho.visible = EstadoJogo.desenho_estado == EstadoJogo.Desenho.NO_INVENTARIO

	icone_desenho.visible = slot_desenho.visible and item_arrastado != "desenho"

	var tem_item = false

	for slot in barra.get_children():
		if slot.visible:
			tem_item = true

	barra.visible = tem_item

func _on_icone_ursinho_gui_input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		iniciar_arrasto("ursinho")

func _on_icone_desenho_gui_input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		iniciar_arrasto("desenho")

func iniciar_arrasto(item):

	if item == "ursinho" and EstadoJogo.ursinho_estado != EstadoJogo.Ursinho.SEGURANDO:
		return

	if item == "desenho" and EstadoJogo.desenho_estado != EstadoJogo.Desenho.NO_INVENTARIO:
		return

	item_arrastado = item

	if item == "ursinho":
		arrasto.texture = icone_ursinho.texture
	else:
		arrasto.texture = icone_desenho.texture

	arrasto.visible = true

	mover_arrasto()

	atualizar()

func _process(delta):

	if item_arrastado != "":
		mover_arrasto()

func mover_arrasto():

	arrasto.global_position = arrasto.get_global_mouse_position() - arrasto.size / 2

func _input(event):

	if item_arrastado != "" and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		soltar()

func soltar():

	var item = item_arrastado

	item_arrastado = ""

	arrasto.visible = false

	var mesa = get_tree().get_first_node_in_group("mesa")
	var inspecao = get_tree().get_first_node_in_group("inspecao_gaveta")
	var ursinho_cama = get_tree().get_first_node_in_group("ursinho_cama")

	if item == "ursinho":

		if inspecao and mesa and inspecao.visible and mesa.gaveta_aberta == 2:
			EstadoJogo.mudar_ursinho(EstadoJogo.Ursinho.DEVOLVIDO)

		elif not EstadoJogo.ui_aberta and ursinho_cama and ursinho_cama.mouse_em_cima():
			EstadoJogo.mudar_ursinho(EstadoJogo.Ursinho.NO_LUGAR)

	elif item == "desenho":

		if inspecao and mesa and inspecao.visible and mesa.gaveta_aberta == 1:
			EstadoJogo.mudar_desenho(EstadoJogo.Desenho.LIMPO)

	atualizar()
