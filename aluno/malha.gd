extends Node2D

func calcular(origem: Vector2, destino: Vector2) -> PackedVector2Array:
	var mapa = get_world_2d().navigation_map
	return NavigationServer2D.map_get_path(mapa, origem, destino, true)
