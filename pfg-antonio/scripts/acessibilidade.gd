extends Node

const ARQUIVO = "user://acessibilidade.cfg"

const TAMANHO_MINIMO_HITBOX = 110.0

const FATOR_FONTE = 1.25
const ALARGAMENTO_PAINEL = 70.0
const COR_DESTAQUE = Color(1.0, 1.0, 0.55)

const OPCOES = [
	"hitbox_ampliada",
	"destaque_interativos",
	"fonte_ampliada",
	"legendas",
	"dicas",
	"navegacao_teclado",
	"wasd",
]

const TECLAS_WASD = {
	"ui_left": KEY_A,
	"ui_right": KEY_D,
	"ui_up": KEY_W,
	"ui_down": KEY_S,
}

signal legenda_emitida(texto)
signal opcoes_mudaram

var hitbox_ampliada = false
var destaque_interativos = false
var fonte_ampliada = false
var legendas = false
var dicas = false
var navegacao_teclado = false
var wasd = false

var paineis_conectados = []

func _ready():

	carregar()

	aplicar_wasd()

func definir(opcao, valor):

	set(opcao, valor)

	aplicar_tudo()

	salvar()

	opcoes_mudaram.emit()

func aplicar_tudo():

	aplicar_hitbox()
	aplicar_destaque()
	aplicar_fonte()
	aplicar_wasd()
	aplicar_foco()

func aplicar_hitbox():

	for objeto in get_tree().get_nodes_in_group("objeto_interativo"):
		for filho in objeto.get_children():
			if filho is CollisionShape2D and filho.shape is RectangleShape2D:

				filho.scale = Vector2.ONE

				if hitbox_ampliada:

					var mundo = filho.shape.size * objeto.global_scale.abs()

					filho.scale = Vector2(
						max(1.0, TAMANHO_MINIMO_HITBOX / mundo.x),
						max(1.0, TAMANHO_MINIMO_HITBOX / mundo.y)
					)

func aplicar_destaque():

	var cor = COR_DESTAQUE if destaque_interativos else Color(1, 1, 1)

	for objeto in get_tree().get_nodes_in_group("objeto_interativo"):
		objeto.modulate = cor

func aplicar_fonte():

	aplicar_fonte_em(get_tree().root)

	for grupo in ["escolha_panel", "gaveta_panel"]:

		var painel = get_tree().get_first_node_in_group(grupo)

		if painel:
			alargar_painel(painel)

func aplicar_fonte_em(no):

	if no is Control and no.has_theme_font_size_override("font_size"):

		if not no.has_meta("fonte_original"):
			no.set_meta("fonte_original", no.get_theme_font_size("font_size"))

		var tamanho = no.get_meta("fonte_original")

		if fonte_ampliada:
			tamanho = int(round(tamanho * FATOR_FONTE))

		no.add_theme_font_size_override("font_size", tamanho)

	for filho in no.get_children():
		aplicar_fonte_em(filho)

func alargar_painel(painel):

	var extra = ALARGAMENTO_PAINEL if fonte_ampliada else 0.0

	ajustar_offset(painel, "offset_left", -extra)
	ajustar_offset(painel, "offset_right", extra)

	for filho in painel.get_children():
		if filho is Button:
			if filho.anchor_left == 0.0:
				ajustar_offset(filho, "offset_right", extra)
			else:
				ajustar_offset(filho, "offset_left", -extra)

func ajustar_offset(no, propriedade, extra):

	var chave = "original_" + propriedade

	if not no.has_meta(chave):
		no.set_meta(chave, no.get(propriedade))

	no.set(propriedade, no.get_meta(chave) + extra)

func aplicar_wasd():

	for acao in TECLAS_WASD:

		var tecla = TECLAS_WASD[acao]

		var existente = null

		for evento in InputMap.action_get_events(acao):
			if evento is InputEventKey and evento.physical_keycode == tecla:
				existente = evento

		if wasd and existente == null:

			var evento = InputEventKey.new()
			evento.physical_keycode = tecla

			InputMap.action_add_event(acao, evento)

		elif not wasd and existente != null:

			InputMap.action_erase_event(acao, existente)

func aplicar_foco():

	for painel in get_tree().get_nodes_in_group("painel_ui"):
		if not painel in paineis_conectados:
			paineis_conectados.append(painel)
			painel.visibility_changed.connect(_ao_mudar_visibilidade.bind(painel))

func _ao_mudar_visibilidade(painel):

	if navegacao_teclado and painel.visible:

		var alvo = primeiro_focavel(painel)

		if alvo:
			alvo.grab_focus.call_deferred()

func primeiro_focavel(no):

	if no is BaseButton and no.visible and not no.disabled:
		return no

	for filho in no.get_children():

		var achado = primeiro_focavel(filho)

		if achado:
			return achado

	return null

func legenda(texto):

	if legendas:
		legenda_emitida.emit(texto)

func salvar():

	var config = ConfigFile.new()

	for opcao in OPCOES:
		config.set_value("opcoes", opcao, get(opcao))

	config.save(ARQUIVO)

func carregar():

	var config = ConfigFile.new()

	if config.load(ARQUIVO) != OK:
		return

	for opcao in OPCOES:
		set(opcao, config.get_value("opcoes", opcao, false))
