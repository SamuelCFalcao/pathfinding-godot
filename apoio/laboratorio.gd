extends Node2D

const AREA = Rect2(96, 168, 960, 432)
const INICIO = Vector2(168, 384)
const FIM = Vector2(984, 384)
const ILHA = Vector2(984, 576)
const NOMES = ["Grid", "Waypoints", "Navmesh"]
var modo: int = 1
var consultas: int = 0
var destino := FIM
var caminho := PackedVector2Array()
var sincronizado: bool = false
var mensagem: String = "Aguardando sincronização da navegação..."

func _ready() -> void:
	$Planejadores/Grade.configurar()
	$Planejadores/Grade.bloquear(celulas_bloqueadas())
	$Planejadores/Waypoints.adicionar()
	$Planejadores/Waypoints.conectar()
	selecionar(1)
	await get_tree().physics_frame
	await get_tree().physics_frame
	while NavigationServer2D.map_get_iteration_id(get_world_2d().navigation_map) == 0:
		await get_tree().physics_frame
	sincronizado = true
	mensagem = "Clique no mapa ou pressione R para consultar a rota."
	painel()

func celulas_bloqueadas() -> Array:
	var resultado: Array = []
	for x in range(20):
		for y in range(9):
			var posicao = Vector2(120 + x * 48, 192 + y * 48)
			for corpo in $Mapa/Regiao.get_children():
				var tamanho = corpo.get_node("Colisao").shape.size
				if Rect2(corpo.position - tamanho / 2, tamanho).has_point(posicao):
					resultado.append(Vector2i(x, y))
	return resultado

func selecionar(numero: int) -> void:
	modo = numero
	consultas = 0
	destino = FIM
	caminho = PackedVector2Array()
	$Agente.position = INICIO
	$Agente.seguir(caminho)
	$Alvo.position = FIM
	$Rota.points = caminho
	$Visual.modo(numero)
	mensagem = "Clique no mapa ou pressione R para consultar a rota."
	painel()

func pedir(posicao: Vector2) -> void:
	if not sincronizado:
		mensagem = "Aguarde a sincronização da navegação."
		painel()
		return
	if not AREA.has_point(posicao):
		return
	$Agente.position = INICIO
	$Agente.seguir(PackedVector2Array())
	destino = posicao
	var planejador: Node
	if modo == 1:
		planejador = $Planejadores/Grade
		destino = Vector2(planejador.celula(posicao)) * 48 + Vector2(120, 192)
	elif modo == 2:
		planejador = $Planejadores/Waypoints
		destino = ponto_proximo(posicao)
	else:
		planejador = $Planejadores/Malha
	consultas += 1
	caminho = planejador.calcular(INICIO, destino)
	if not caminho.is_empty() and caminho[-1].distance_to(destino) > 2.0:
		caminho = PackedVector2Array()
	$Alvo.position = destino
	$Rota.points = caminho
	$Agente.seguir(caminho)
	mensagem = "Sem rota até o destino. Confira a conexão ou a etapa implementada."
	if not caminho.is_empty():
		mensagem = "Rota pronta. Cada consulta reinicia o agente na origem."
	painel()

func ponto_proximo(posicao: Vector2) -> Vector2:
	var melhor = $Mapa/Pontos.get_child(0).position
	for ponto in $Mapa/Pontos.get_children():
		if ponto.position.distance_squared_to(posicao) < melhor.distance_squared_to(posicao):
			melhor = ponto.position
	return melhor

func painel() -> void:
	$Interface/Titulo.text = "PATHFINDING   /   " + NOMES[modo - 1]
	var comprimento: float = 0.0
	for i in range(1, caminho.size()):
		comprimento += caminho[i - 1].distance_to(caminho[i])
	$Interface/Dados.text = "Consultas: %d    Pontos da rota: %d    Comprimento: %.0f px" % [consultas, caminho.size(), comprimento]
	$Interface/Mensagem.text = mensagem

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_3:
			selecionar(event.keycode - KEY_0)
		elif event.keycode == KEY_R:
			pedir(FIM)
		elif event.keycode == KEY_I:
			pedir(ILHA)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pedir(get_global_mouse_position())
