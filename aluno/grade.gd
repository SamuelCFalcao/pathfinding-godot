extends Node2D

const CELULA = 48
const ORIGEM = Vector2(96, 168)
var grade = AStarGrid2D.new()

func configurar() -> void:
	pass

func bloquear(celulas: Array) -> void:
	pass

func calcular(origem: Vector2, destino: Vector2) -> PackedVector2Array:
	return PackedVector2Array()

func celula(posicao: Vector2) -> Vector2i:
	return Vector2i(((posicao - ORIGEM) / CELULA).floor())
