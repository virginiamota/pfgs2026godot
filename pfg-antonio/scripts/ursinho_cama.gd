extends Sprite2D

@export var sprite_ursinho : Texture2D
@export var sprite_fantasma : Texture2D

func _ready():

	EstadoJogo.ursinho_mudou.connect(atualizar)

	atualizar()

func atualizar():

	match EstadoJogo.ursinho_estado:

		EstadoJogo.Ursinho.NA_GAVETA:
			visible = false

		EstadoJogo.Ursinho.SEGURANDO, EstadoJogo.Ursinho.DEVOLVIDO:
			visible = true
			texture = sprite_fantasma

		EstadoJogo.Ursinho.NO_LUGAR:
			visible = true
			texture = sprite_ursinho

func mouse_em_cima():

	return visible and get_rect().has_point(get_local_mouse_position())
