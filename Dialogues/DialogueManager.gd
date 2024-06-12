extends Node

@onready var text_box_scene = preload("res://Dialogues/text_box.tscn")
@onready var command_label_scene = preload("res://Dialogues/command_label.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
var command_label
var text_box_position: Vector2

var is_dialogue_active = false
var is_dialogue_finished = false
var can_advance_line = false


func start_dialog(lines: Array[String]):
	if is_dialogue_active or get_tree().paused:
		return
	
	dialog_lines = lines
	#text_box_position = position
	_show_text_box()
	
	is_dialogue_active = true
	is_dialogue_finished = false


func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	#text_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false


func _on_text_box_finished_displaying():
	can_advance_line = true


func _unhandled_input(event):
	if event.is_action_pressed("advance_dialogue") and is_dialogue_active and can_advance_line:
		text_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialog_lines.size():
			is_dialogue_active = false
			is_dialogue_finished = true
			current_line_index = 0
			return
			
		_show_text_box()


func show_command_label(n_string):
	command_label = command_label_scene.instantiate()
	command_label.stringa = n_string
	get_tree().root.add_child(command_label)


func end_command_label():
	command_label.end()