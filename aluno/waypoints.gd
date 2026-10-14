extends Node2D

var grafo = AStar2D.new()
@onready var pontos = $"../../Mapa/Pontos".get_children()

func adicionar() -> void:
	for ponto in pontos:
		grafo.add_point(ponto.get_index(), ponto.global_position)

func conectar() -> void:
	for ponto in pontos:
		for vizinho in ponto.vizinhos:
			grafo.connect_points(ponto.get_index(), vizinho)

func calcular(origem: Vector2, destino: Vector2) -> PackedVector2Array:
	if grafo.get_point_count() == 0:
		return PackedVector2Array()
	var a = grafo.get_closest_point(origem)
	var b = grafo.get_closest_point(destino)
	return grafo.get_point_path(a, b)
