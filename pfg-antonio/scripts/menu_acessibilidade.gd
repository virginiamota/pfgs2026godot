extends CanvasLayer

const DURACAO_LEGENDA = 2.0
const DURACAO_DICA = 10.0
const TEXTURA_LAMPADA = "res://sprites/ui/lampada.png"

@onready var painel = $Painel
@onready var legenda_som = $LegendaSom
@onready var dica = $Dica
@onready var icone_dica = $IconeDica

@onready var caixas = {
	"hitbox_ampliada": $Painel/Lista/OpcaoHitbox,
	"destaque_interativos": $Painel/Lista/OpcaoDestaque,
	"fonte_ampliada": $Painel/Lista/OpcaoFonte,
	"legendas": $Painel/Lista/OpcaoLegendas,
	"dicas": $Painel/Lista/OpcaoDicas,
	"navegacao_teclado": $Painel/Lista/OpcaoTeclado,
	"wasd": $Painel/Lista/OpcaoWasd,
}

var tempo_legenda = 0.0
var tempo_dica = 0.0

func _ready():

	painel.visible = false

	legenda_som.visible = false

	dica.visible = false

	if icone_dica.texture == null and ResourceLoader.exists(TEXTURA_LAMPADA):
		icone_dica.texture = load(TEXTURA_LAMPADA)

	for opcao in caixas:
		caixas[opcao].button_pressed = Acessibilidade.get(opcao)
		caixas[opcao].toggled.connect(_ao_alternar.bind(opcao))

	Acessibilidade.legenda_emitida.connect(mostrar_legenda)
	Acessibilidade.opcoes_mudaram.connect(atualizar_dica)

	EstadoJogo.ursinho_mudou.connect(atualizar_dica)
	EstadoJogo.desenho_mudou.connect(atualizar_dica)
	EstadoJogo.progresso_mudou.connect(atualizar_dica)

	Acessibilidade.aplicar_tudo()

	atualizar_dica()

func _ao_alternar(valor, opcao):

	Acessibilidade.definir(opcao, valor)

func _on_botao_menu_gui_input(event):

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

func _on_icone_dica_gui_input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		mostrar_dica()

func mostrar_dica():

	dica.text = texto_dica()

	dica.visible = true

	tempo_dica = DURACAO_DICA

func atualizar_dica():

	icone_dica.visible = Acessibilidade.dicas

	if not Acessibilidade.dicas:
		dica.visible = false

	if dica.visible:
		dica.text = texto_dica()

func texto_dica():

	if EstadoJogo.ursinho_estado == EstadoJogo.Ursinho.NA_GAVETA:
		return "Dica: as gavetas podem guardar algo."

	if EstadoJogo.ursinho_estado != EstadoJogo.Ursinho.NO_LUGAR:
		return "Dica: o ursinho gostaria de voltar para a cama."

	if EstadoJogo.desenho_estado == EstadoJogo.Desenho.RABISCADO:
		return "Dica: chacoalhe ou clique no desenho rabiscado para revelá-lo."

	if not (EstadoJogo.progresso.has("Desenho1") and EstadoJogo.progresso.has("Desenho2") and EstadoJogo.progresso.has("Desenho3")):
		return "Dica: os desenhos do mural podem ser reorganizados."

	if not EstadoJogo.progresso.has("diario"):
		return "Dica: o travesseiro da cama parece fora do lugar."

	return "Você explorou tudo por enquanto. Confira o bloco de notas."

func mostrar_legenda(texto):

	legenda_som.text = texto

	legenda_som.visible = true

	tempo_legenda = DURACAO_LEGENDA

func _process(delta):

	if tempo_legenda > 0.0:

		tempo_legenda -= delta

		if tempo_legenda <= 0.0:
			legenda_som.visible = false

	if tempo_dica > 0.0:

		tempo_dica -= delta

		if tempo_dica <= 0.0:
			dica.visible = false