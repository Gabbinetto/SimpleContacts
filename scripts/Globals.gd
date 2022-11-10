extends Node

const recents_path : = 'user://verdi_recenti.csv'

var path_to_pass : = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + '/SenzaNome.csv'
var recents = PackedStringArray([])

func _notification(what):
#	var file = FileAccess.open('/home/exit_notification.txt', FileAccess.WRITE)
#	file.store_line(str(what))
	if what == 11:
		save_recents()
		get_tree().quit()

func _ready() -> void:
#	OS.shell_open(OS.get_user_data_dir())
	load_recents()

func add_recent(path : String):
	var path_index = recents.find(path)
	if path_index != -1:
		recents.remove_at(path_index)
	recents.insert(0, path)
	
	save_recents()

func save_recents():
	
	var file = FileAccess.open(recents_path, FileAccess.WRITE)
	for line in recents:
		file.store_line(line)

func load_recents():
	if not FileAccess.file_exists(recents_path):
		return
	
	var file = FileAccess.open(recents_path, FileAccess.READ)
	while !file.eof_reached():
		recents.append(file.get_line())
