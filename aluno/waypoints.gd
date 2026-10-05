extends Node2D

var grafo = AStar2D.new()
@onready var pontos = $"../../Mapa/Pontos".get_children()

func adicionar() -> void:
	pass

func conectar() -> void:
	pass

func calcular(origem: Vector2, destino: Vector2) -> PackedVector2Array:
	return PackedVector2Array()
