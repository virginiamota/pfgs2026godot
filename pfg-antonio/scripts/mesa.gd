extends Area2D

@onready var sprite = $Sprite2D
@onready var som_abrir = $SomAbrir
@onready var som_fechar = $SomFechar

@export var sprite_fechada : Texture2D
@export var sprite_gaveta1 : Texture2D
@export var sprite_gaveta2 : Texture2D

# 0 = nenhuma, 1 = gaveta 1, 2 = gaveta 2
var gaveta_aberta = 0

func _ready():
	if sprite_fechada:
		trocar_sprite(sprite_fechada)

func trocar_sprite(textura):

	sprite.texture = textura

	sprite.offset.x = (sprite_fechada.get_width() - textura.get_width()) / 2.0

func _input_event(viewport, event, shape_idx):

	if EstadoJogo.ui_aberta:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		var gaveta = shape_owner_get_owner(shape_find_owner(shape_idx))

		if gaveta.name == "gaveta1":
			abrir_gaveta(1)
		elif gaveta.name == "gaveta2":
			abrir_gaveta(2)


func abrir_gaveta(numero):

	gaveta_aberta = numero

	if numero == 1:
		trocar_sprite(sprite_gaveta1)
	elif numero == 2:
		trocar_sprite(sprite_gaveta2)

	som_abrir.play()

	Acessibilidade.legenda("[gaveta abre]")

	EstadoJogo.ui_aberta = true

	var painel = get_tree().get_first_node_in_group("gaveta_panel")

	if painel:
		painel.visible = true


func fechar():

	gaveta_aberta = 0

	trocar_sprite(sprite_fechada)

	som_fechar.play()

	Acessibilidade.legenda("[gaveta fecha]")
