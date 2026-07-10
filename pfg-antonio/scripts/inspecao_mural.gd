extends Control

const VELOCIDADE = 900.0
const BORDA_TELA = 48.0

@onready var imagem = $Imagem

var desenho_segurado = null
var offset_segurada = Vector2.ZERO

func _ready():

	visible = false

	for desenho in imagem.get_children():

		desenho.gui_input.connect(_on_desenho_gui_input.bind(desenho))

		if EstadoJogo.desenhos_mural.has(desenho.name):
			desenho.position = EstadoJogo.desenhos_mural[desenho.name]

func abrir():

	visible = true

	imagem.position = Vector2.ZERO

func _process(delta):

	if not visible:
		return

	mover_visao(delta)

	if desenho_segurado:
		arrastar_desenho()

func mover_visao(delta):

	var direcao = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direcao.x += 1

	if Input.is_action_pressed("ui_left"):
		direcao.x -= 1

	if Input.is_action_pressed("ui_down"):
		direcao.y += 1

	if Input.is_action_pressed("ui_up"):
		direcao.y -= 1

	var mouse = get_global_mouse_position()

	if mouse.x < BORDA_TELA:
		direcao.x -= 1
	elif mouse.x > size.x - BORDA_TELA:
		direcao.x += 1

	if mouse.y < BORDA_TELA:
		direcao.y -= 1
	elif mouse.y > size.y - BORDA_TELA:
		direcao.y += 1

	direcao.x = clamp(direcao.x, -1, 1)
	direcao.y = clamp(direcao.y, -1, 1)

	imagem.position -= direcao * VELOCIDADE * delta

	imagem.position.x = clamp(imagem.position.x, min(size.x - imagem.size.x, 0.0), 0.0)
	imagem.position.y = clamp(imagem.position.y, min(size.y - imagem.size.y, 0.0), 0.0)

func _on_desenho_gui_input(event, desenho):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		desenho_segurado = desenho

		offset_segurada = desenho.get_local_mouse_position()

func arrastar_desenho():

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		soltar_desenho()
		return

	var pos = imagem.get_local_mouse_position() - offset_segurada

	pos.x = clamp(pos.x, 0.0, imagem.size.x - desenho_segurado.size.x)
	pos.y = clamp(pos.y, 0.0, imagem.size.y - desenho_segurado.size.y)

	desenho_segurado.position = pos

func soltar_desenho():

	EstadoJogo.desenhos_mural[desenho_segurado.name] = desenho_segurado.position

	EstadoJogo.registrar_progresso(desenho_segurado.name)

	desenho_segurado = null

func _on_botao_voltar_pressed():

	visible = false

	EstadoJogo.ui_aberta = false
