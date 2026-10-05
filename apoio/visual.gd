extends Node2D

func _ready() -> void:
	for x in range(21):
		linha($Grade, Vector2(96 + x * 48, 168), Vector2(96 + x * 48, 600))
	for y in range(10):
		linha($Grade, Vector2(96, 168 + y * 48), Vector2(1056, 168 + y * 48))
	for ponto in $"../Mapa/Pontos".get_children():
		for id in ponto.vizinhos:
			linha($Arestas, ponto.position, $"../Mapa/Pontos".get_child(id).position)
	var malha = $"../Mapa/Regiao".navigation_polygon
	var vertices = malha.vertices
	for i in range(malha.get_polygon_count()):
		var pontos := PackedVector2Array()
		for id in malha.get_polygon(i):
			pontos.append(vertices[id])
		var poligono := Polygon2D.new()
		poligono.polygon = pontos
		poligono.color = Color(0.2, 0.65, 0.45, 0.10 + (i % 3) * 0.04)
		$Malha.add_child(poligono)
		for j in range(pontos.size()):
			linha($Malha, pontos[j], pontos[(j + 1) % pontos.size()])

func linha(pai: Node, a: Vector2, b: Vector2) -> void:
	var no := Line2D.new()
	no.points = PackedVector2Array([a, b])
	no.width = 1.0
	no.default_color = Color(0.42, 0.55, 0.6, 0.42)
	pai.add_child(no)

func modo(numero: int) -> void:
	$Grade.visible = numero == 1
	$Arestas.visible = numero == 2
	$Malha.visible = numero == 3
	$"../Mapa/Pontos".visible = numero == 2
