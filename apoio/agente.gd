extends CharacterBody2D

const RAPIDEZ = 180.0
var rota := PackedVector2Array()
var indice: int = 0
var contatos: int = 0

func seguir(caminho: PackedVector2Array) -> void:
	rota = caminho
	indice = 0
	velocity = Vector2.ZERO
	contatos = 0

func _physics_process(delta: float) -> void:
	if indice >= rota.size():
		velocity = Vector2.ZERO
		return
	var diferenca = rota[indice] - global_position
	if diferenca.length() < 0.5:
		indice += 1
		return
	velocity = diferenca.normalized() * minf(RAPIDEZ, diferenca.length() / delta)
	move_and_slide()
	contatos += get_slide_collision_count()
	if velocity.length_squared() > 1.0:
		$Corpo.rotation = velocity.angle()
