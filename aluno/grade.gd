extends Node2D

const CELULA = 48
const ORIGEM = Vector2(96, 168)
var grade = AStarGrid2D.new()

func configurar() -> void:
	grade.region = Rect2i(0, 0, 20, 9)
	grade.cell_size = Vector2(CELULA, CELULA)
	grade.offset = ORIGEM + Vector2(24, 24)
	grade.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grade.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grade.update()

func bloquear(celulas: Array) -> void:
	for id in celulas:
		grade.set_point_solid(id)



func calcular(origem: Vector2, destino: Vector2) -> PackedVector2Array:
	var a = celula(origem)
	var b = celula(destino)
	if not grade.is_in_boundsv(a) or not grade.is_in_boundsv(b):
		return PackedVector2Array()
	if grade.is_point_solid(a) or grade.is_point_solid(b):
		return PackedVector2Array()
	return grade.get_point_path(a, b)

func celula(posicao: Vector2) -> Vector2i:
	return Vector2i(((posicao - ORIGEM) / CELULA).floor())
