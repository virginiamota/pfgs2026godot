extends CanvasLayer

@onready var painel = $Painel
@onready var olho = $Painel/Folha/ItemDiario/Olho
@onready var cadeado = $Painel/Folha/ItemDiario/Cadeado

@onready var itens = {
	"diario": $Painel/Folha/ItemDiario,
	"ursinho": $Painel/Folha/ItemUrsinho,
	"desenho_limpo": $Painel/Folha/ItemDesenhoLimpo,
	"Desenho1": $Painel/Folha/ItemDesenho1,
	"Desenho2": $Painel/Folha/ItemDesenho2,
	"Desenho3": $Painel/Folha/ItemDesenho3,
}

func _ready():

	painel.visible = false

	EstadoJogo.progresso_mudou.connect(atualizar)

	atualizar()

func atualizar():

	for chave in itens:
		itens[chave].visible = EstadoJogo.progresso.has(chave)

	olho.visible = EstadoJogo.progresso.get("diario", "") == "olhou"
	cadeado.visible = EstadoJogo.progresso.get("diario", "") == "respeitou"

func _on_icone_notas_gui_input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		abrir()

func abrir():

	if EstadoJogo.ui_aberta:
		return

	EstadoJogo.ui_aberta = true

	painel.visible = true

func _on_botao_voltar_pressed():

	painel.visible = false

	EstadoJogo.ui_aberta = false
