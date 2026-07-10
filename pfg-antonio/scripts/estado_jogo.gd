extends Node

enum Ursinho { NA_GAVETA, SEGURANDO, DEVOLVIDO, NO_LUGAR }
enum Desenho { RABISCADO, LIMPO, NO_INVENTARIO }

signal ursinho_mudou
signal desenho_mudou
signal progresso_mudou

var ui_aberta = false

var ursinho_estado = Ursinho.NA_GAVETA

var desenho_estado = Desenho.RABISCADO
var rabisco_restante = 1.0

var desenhos_mural = {}

var progresso = {}

func mudar_ursinho(novo_estado):

	ursinho_estado = novo_estado

	ursinho_mudou.emit()

	if novo_estado == Ursinho.NO_LUGAR:
		registrar_progresso("ursinho")

func mudar_desenho(novo_estado):

	desenho_estado = novo_estado

	desenho_mudou.emit()

	if novo_estado == Desenho.LIMPO:
		registrar_progresso("desenho_limpo")

func registrar_progresso(chave, valor = true):

	progresso[chave] = valor

	progresso_mudou.emit()
