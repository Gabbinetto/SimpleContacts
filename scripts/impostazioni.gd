extends Panel
class_name Impostazioni

var categories : VBoxContainer
var old_names : Dictionary
var last_category_selected : LineEdit
var old_text : String
var on_focus_changed : Callable

signal closed(_categories : Array[String])

func _ready() -> void:
	%Chiudi.pressed.connect(close)
	%Aggiungi.pressed.connect(add_category)
	%Rimuovi.pressed.connect(func():
		print(last_category_selected)
		if is_instance_valid(last_category_selected):
			last_category_selected.queue_free()
	)
	%Sopra.pressed.connect(func(): _move_category(-1))
	%Sotto.pressed.connect(func(): _move_category(1))
	
	
	categories = $Panel/Voci/ScrollContainer/VBoxContainer
	
	on_focus_changed = func(node : Control):
		if node is LineEdit:# and node.owner == self:
				last_category_selected = node
				old_text = node.text
	
	

func add_category(content : = ''):
	var category : = LineEdit.new()
	category.placeholder_text = 'Voce'
	category.text = content
	category.text_changed.connect(
		func(new_text : String):
			for line in categories.get_children():
				if line == category:
					continue
				if new_text == line.text or (new_text.substr(new_text.length()-1) == ' ' and new_text.length() >= old_text.length()):
					category.text = old_text
					category.caret_column = old_text.length()
					return

			if old_text in old_names.keys():
				old_names[new_text] = old_names[old_text]
				old_names.erase(old_text)

			old_text = new_text
	)
	categories.add_child(category)
	category.set_owner(self)
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			close()

func close():
	hide()
	for node in categories.get_children():
		if node.text.replace(' ', '') == '':
			node.queue_free()
	
	
	closed.emit(get_categories())

func open():
	show()
	old_names.clear()
	for node in categories.get_children():
		var text : String = node.text
		old_names[text] = text


func _move_category(offset : int):
	var prev_index = categories.get_children().find(last_category_selected)
	categories.move_child(last_category_selected, prev_index + offset)

func get_autosave_time():
	return $Panel/Autosalvataggio/SpinBox.value * 60

func get_categories() -> Array[Dictionary]:
	var _categories : Array[Dictionary] = []
	for node in categories.get_children():
		var out : = {}
		out['new'] = node.text
		out['old'] = old_names.get(node.text)
		out['index'] = categories.get_children().find(node)
		
		_categories.append(out)
		
	return _categories

func get_categories_names() -> Array[String]:
	var output = []
	for node in categories.get_children():
		output.append(node.text)
	return output
