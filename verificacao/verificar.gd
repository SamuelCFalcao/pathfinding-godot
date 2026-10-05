extends Node

@export var etapa: int = 3
signal terminou(falhas: int)
var total := 0
var falhas := 0
var cena: Node2D
var painel: Label

func _ready() -> void:
	painel = Label.new()
	painel.position = Vector2(40, 20)
	painel.add_theme_color_override("font_color", Color("17334a"))
	painel.add_theme_font_size_override("font_size", 23)
	add_child(painel)
	painel.text = "Verificando..."
	call_deferred("executar")

func conferir(nome: String, passou: bool) -> void:
	total += 1
	if not passou:
		falhas += 1
	print(("OK: " if passou else "FALHA: ") + nome)

func quadros(n: int) -> void:
	for i in range(n):
		await get_tree().physics_frame
		await get_tree().process_frame

func tecla(tecla_id: Key) -> void:
	var evento := InputEventKey.new()
	evento.keycode = tecla_id
	evento.pressed = true
	cena._unhandled_input(evento)

func comprimento(rota: PackedVector2Array) -> float:
	var valor := 0.0
	for i in range(1, rota.size()):
		valor += rota[i - 1].distance_to(rota[i])
	return valor

func base() -> void:
	cena = load("res://cenas/laboratorio.tscn").instantiate()
	add_child(cena)
	cena.set_process_unhandled_input(false)
	cena.pedir(cena.FIM)
	conferir("não consulta navegação antes da sincronização", cena.consultas == 0)
	for i in range(120):
		if cena.sincronizado:
			break
		await quadros(1)
	conferir("mapa nativo sincroniza", cena.sincronizado)
	conferir("agente usa colisão nativa", cena.get_node("Agente") is CharacterBody2D)
	conferir("malha contém polígonos gerados pelo bake", cena.get_node("Mapa/Regiao").navigation_polygon.get_polygon_count() > 0)
	conferir("raio do bake reserva espaço para o corpo", cena.get_node("Mapa/Regiao").navigation_polygon.agent_radius > cena.get_node("Agente/Colisao").shape.radius)
	conferir("waypoints são nove Marker2D", cena.get_node("Mapa/Pontos").get_child_count() == 9 and cena.get_node("Mapa/Pontos/P0") is Marker2D)
	conferir("grade deriva bloqueios dos três corpos", cena.celulas_bloqueadas().size() == 16)
	for n in range(1, 4):
		tecla(KEY_0 + n)
		conferir("tecla %d seleciona a representação" % n, cena.modo == n and cena.consultas == 0 and cena.caminho.is_empty())
	cena.pedir(Vector2(-100, -100))
	conferir("clique fora do mapa não inicia consulta", cena.consultas == 0)

func executar_rota(numero: int) -> void:
	cena.selecionar(numero)
	tecla(KEY_R)
	var agente = cena.get_node("Agente")
	conferir("modo %d entrega rota completa" % numero, not cena.caminho.is_empty() and cena.caminho[0].distance_to(cena.INICIO) < 1 and cena.caminho[-1].distance_to(cena.FIM) < 1)
	await quadros(600)
	conferir("modo %d chega ao alvo na cena real" % numero, agente.position.distance_to(cena.FIM) < 1 and agente.indice == agente.rota.size())
	conferir("modo %d percorre a rota sem colisões" % numero, agente.contatos == 0)
	conferir("modo %d mantém rota sem consultar a cada quadro" % numero, cena.consultas == 1)
	tecla(KEY_I)
	conferir("modo %d rejeita a ilha desconectada" % numero, cena.caminho.is_empty() and cena.get_node("Rota").points.is_empty())
	await quadros(30)
	conferir("modo %d limpa rota antiga e mantém agente parado" % numero, agente.position.distance_to(cena.INICIO) < 1 and agente.velocity == Vector2.ZERO)

func grid() -> void:
	var p = cena.get_node("Planejadores/Grade")
	conferir("grade tem 20 por 9 células", p.grade.region == Rect2i(0, 0, 20, 9))
	conferir("grade permite somente quatro direções", p.grade.diagonal_mode == AStarGrid2D.DIAGONAL_MODE_NEVER)
	conferir("estimativa Manhattan corresponde ao movimento", p.grade.default_estimate_heuristic == AStarGrid2D.HEURISTIC_MANHATTAN)
	var rota: PackedVector2Array = p.calcular(cena.INICIO, cena.FIM)
	conferir("A* encontra custo mínimo conhecido de 23 passos", rota.size() == 24 and is_equal_approx(comprimento(rota), 1104.0))
	var valido := not rota.is_empty()
	for i in range(rota.size()):
		valido = valido and not p.grade.is_point_solid(p.celula(rota[i]))
		if i > 0:
			var d = (p.celula(rota[i]) - p.celula(rota[i - 1])).abs()
			valido = valido and d.x + d.y == 1
	conferir("todos os passos são adjacentes e caminháveis", valido)
	conferir("grade rejeita alvo sólido", p.calcular(cena.INICIO, Vector2(552, 384)).is_empty())
	conferir("grade rejeita origem sólida", p.calcular(Vector2(552, 384), cena.FIM).is_empty())
	conferir("grade rejeita coordenadas fora da região", p.calcular(Vector2(-20, -20), cena.FIM).is_empty())
	var igual: PackedVector2Array = p.calcular(cena.INICIO, cena.INICIO)
	conferir("origem igual ao destino retorna um ponto", igual.size() == 1 and igual[0] == cena.INICIO)
	conferir("conversão de coordenadas considera offset e células", p.celula(cena.INICIO) == Vector2i(1, 4) and p.grade.get_point_position(Vector2i(1, 4)) == cena.INICIO)
	await executar_rota(1)

func waypoints() -> void:
	var p = cena.get_node("Planejadores/Waypoints")
	conferir("AStar2D registra nove pontos", p.grafo.get_point_count() == 9)
	conferir("conexões são bidirecionais", p.grafo.are_points_connected(0, 1) and p.grafo.are_points_connected(1, 0))
	var rota: PackedVector2Array = p.calcular(cena.INICIO, cena.FIM)
	conferir("waypoints encontram custo mínimo conhecido", is_equal_approx(comprimento(rota), 1152.0))
	conferir("rota inversa mantém o custo", is_equal_approx(comprimento(p.calcular(cena.FIM, cena.INICIO)), 1152.0))
	conferir("ponto próximo seleciona o waypoint existente", p.grafo.get_closest_point(Vector2(980, 380)) == 5)
	p.grafo.disconnect_points(2, 3)
	var desvio: PackedVector2Array = p.calcular(cena.INICIO, cena.FIM)
	conferir("remover aresta superior força rota inferior", desvio.has(Vector2(456, 552)) and not desvio.has(Vector2(456, 216)))
	p.grafo.connect_points(2, 3)
	p.grafo.set_point_weight_scale(2, 3.0)
	conferir("custo maior desvia do ponto caro", not p.calcular(cena.INICIO, cena.FIM).has(Vector2(456, 216)))
	p.grafo.set_point_weight_scale(2, 1.0)
	await executar_rota(2)

func malha() -> void:
	var p = cena.get_node("Planejadores/Malha")
	var rota: PackedVector2Array = p.calcular(cena.INICIO, cena.FIM)
	var tamanho = comprimento(rota)
	conferir("malha contorna parede com rota menor que a grade", tamanho > 816 and tamanho < 1104)
	var diagonal := false
	for i in range(1, rota.size()):
		var d = (rota[i] - rota[i - 1]).abs()
		diagonal = diagonal or (d.x > 1 and d.y > 1)
	conferir("rota da malha usa segmentos em ângulos livres", diagonal)
	var mapa = cena.get_world_2d().navigation_map
	var bruta = NavigationServer2D.map_get_path(mapa, cena.INICIO, cena.ILHA, true)
	conferir("servidor não alcança ilha isolada", bruta.is_empty() or bruta[-1].distance_to(cena.ILHA) > 2)
	cena.selecionar(3)
	cena.pedir(Vector2(576, 384))
	conferir("apoio rejeita destino projetado na parede", cena.caminho.is_empty())
	await executar_rota(3)

func executar() -> void:
	await base()
	if etapa >= 1:
		await grid()
	if etapa >= 2:
		await waypoints()
	if etapa >= 3:
		await malha()
	cena.free()
	painel.text = "Etapa %d: %d/%d verificações passaram." % [etapa, total - falhas, total]
	print("RESULTADO: " + painel.text)
	terminou.emit(falhas)
