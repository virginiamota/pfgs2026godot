extends Area2D

const DISTANCIA_FECHAR = 1200.0

@onready var sprite = $Travesseiro

@export var sprite_fechada : Texture2D
@export var sprite_aberta : Texture2D

var aberta = false

@onready var diario = $"../Diario"
@onready var camera = $"../../Camera2D"

func _ready():
	sprite.texture = sprite_fechada

func _process(delta):

	if not aberta or EstadoJogo.ui_aberta:
		return

	if abs(camera.position.x - sprite.global_position.x) > DISTANCIA_FECHAR:
		resetar()

func _input_event(viewport, event, shape_idx):

	if EstadoJogo.ui_aberta:
		return

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed and not aberta:
				revelar_diario()


func revelar_diario():

	aberta = true

	sprite.texture = sprite_aberta

	print("Há algo embaixo do travesseiro...")

	diario.visible = true
	diario.input_pickable = true

func resetar():

	aberta = false

	sprite.texture = sprite_fechada

	diario.visible = false
	diario.input_pickable = false

	diario.encontrado = false
