extends Node

const BORDA_TELA = 48.0

@onready var camera = $"../Camera2D"

var speed = 600

var limite_esquerda = -490
var limite_direita = 490

func _process(delta):

	if EstadoJogo.ui_aberta:
		return

	var direcao = 0

	if Input.is_action_pressed("ui_right"):
		direcao += 1

	if Input.is_action_pressed("ui_left"):
		direcao -= 1

	var mouse = get_viewport().get_mouse_position()
	var largura = get_viewport().get_visible_rect().size.x

	if mouse.x < BORDA_TELA:
		direcao -= 1
	elif mouse.x > largura - BORDA_TELA:
		direcao += 1

	direcao = clamp(direcao, -1, 1)

	camera.position.x += direcao * speed * delta

	camera.position.x = clamp(
		camera.position.x,
		limite_esquerda,
		limite_direita
	)
