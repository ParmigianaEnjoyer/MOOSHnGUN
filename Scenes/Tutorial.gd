extends Node3D

func _ready():
	GlobalVar.livello = 0

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file("res://MenuPrincipale/menu.tscn")