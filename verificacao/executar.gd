extends SceneTree

func _initialize() -> void:
	call_deferred("executar")

func executar() -> void:
	var teste = load("res://verificacao/verificar.gd").new()
	teste.etapa = int(FileAccess.get_file_as_string("res://etapa.txt"))
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--etapa="):
			teste.etapa = int(arg.get_slice("=", 1))
	root.add_child(teste)
	var falhas = await teste.terminou
	quit(0 if falhas == 0 else 1)
