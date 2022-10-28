extends CanvasLayer

@onready var recenti = $Panel/Scroll/Recenti

const Recent : = preload('res://recent_button.tscn')
const main_scene_path = 'res://main.tscn'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	await get_tree().create_timer(0.2).timeout
	
	for path in Globals.recents:
		if path == '' or not FileAccess.file_exists(path):
			continue

		var button = Recent.instantiate()
		button.path = path
		recenti.add_child(button)
		button.connect('pressed', _go_to_main)

func _go_to_main():
	print('change')
	get_tree().change_scene_to_file(main_scene_path)
