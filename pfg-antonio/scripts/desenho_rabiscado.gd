extends TextureRect

const LIMPEZA_POR_SACUDIDA = 0.08
const MOVIMENTO_MINIMO = 4.0

@onready var rabisco = $Rabisco

var posicao_inicial = Vector2.ZERO
var segurando = false
var ultima_pos = Vector2.ZERO
var ultima_direcao = 0.0

func _ready():

	posicao_inicial = position

	EstadoJogo.desenho_mudou.connect(atualizar)

	atualizar()

func atualizar():

	rabisco.visible = EstadoJogo.desenho_estado == EstadoJogo.Desenho.RABISCADO

	rabisco.modulate.a = EstadoJogo.rabisco_restante

func resetar_posicao():

	if segurando:
		return

	position = posicao_inicial

func _gui_input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		if EstadoJogo.desenho_estado == EstadoJogo.Desenho.RABISCADO:
			iniciar_segurada()

		elif EstadoJogo.desenho_estado == EstadoJogo.Desenho.LIMPO:
			coletar()

func iniciar_segurada():

	segurando = true

	ultima_pos = get_global_mouse_position()

	ultima_direcao = 0.0

func _process(delta):

	if not segurando:
		return

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		soltar()
		return

	var pos = get_global_mouse_position()

	position += pos - ultima_pos

	var dx = pos.x - ultima_pos.x

	if abs(dx) > MOVIMENTO_MINIMO:

		var direcao = sign(dx)

		if ultima_direcao != 0.0 and direcao != ultima_direcao:
			chacoalhar()

		ultima_direcao = direcao

	ultima_pos = pos

func chacoalhar():

	EstadoJogo.rabisco_restante = max(EstadoJogo.rabisco_restante - LIMPEZA_POR_SACUDIDA, 0.0)

	rabisco.modulate.a = EstadoJogo.rabisco_restante

	if EstadoJogo.rabisco_restante <= 0.0:
		EstadoJogo.mudar_desenho(EstadoJogo.Desenho.LIMPO)

func soltar():

	segurando = false

	position = posicao_inicial

func coletar():

	EstadoJogo.mudar_desenho(EstadoJogo.Desenho.NO_INVENTARIO)
