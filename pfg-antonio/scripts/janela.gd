extends Area2D

@onready var sprite = $Sprite2D
@onready var som_abrir = $SomAbrir
@onready var som_fechar = $SomFechar

@export var sprite_fechada : Texture2D
@export var sprite_aberta : Texture2D

var aberta = false

func _ready():
	sprite.texture = sprite_fechada

func _input_event(viewport, event, shape_idx):

	if EstadoJogo.ui_aberta:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		alternar()

func alternar():

	aberta = not aberta

	if aberta:
		sprite.texture = sprite_aberta
		som_abrir.play()
	else:
		sprite.texture = sprite_fechada
		som_fechar.play()
