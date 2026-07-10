extends Control

@export var paginas : Array[Texture2D]

@onready var pagina = $Pagina

var indice = 0

func _ready():

	visible = false

func abrir():

	visible = true

	indice = 0

	atualizar()

func atualizar():

	if indice >= 0 and indice < paginas.size():
		pagina.texture = paginas[indice]

func _input(event):

	if not visible:
		return

	if event.is_action_pressed("ui_right"):
		passar_pagina(1)

	elif event.is_action_pressed("ui_left"):
		passar_pagina(-1)

func passar_pagina(sentido):

	if paginas.is_empty():
		return

	indice = posmod(indice + sentido, paginas.size())

	atualizar()

func _on_pagina_gui_input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		passar_pagina(1)

func _on_botao_voltar_pressed():

	visible = false
