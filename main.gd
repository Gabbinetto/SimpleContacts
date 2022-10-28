extends CanvasLayer

const Element = preload('res://element.tscn')

var autosave_on = false

@onready var save_dialog : FileDialog = $SaveDialog
@onready var load_dialog : FileDialog = $LoadDialog
@onready var elements : VBoxContainer = $Panel/ScrollContainer/Elementi
@onready var sort_buttons : Array[Node] = $Panel/Ordini.get_children()

var current_file = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + '/SenzaNome.csv':
	set(value):
		current_file = value
		%Percorso.text = current_file

func _ready() -> void:
	current_file = Globals.path_to_pass
	
	%AddButton.pressed.connect(_add_element)
	
	for button in sort_buttons:
		button.pressed.connect(
			func(): _sort_button(button.text)
		)

	%AutosaveButton.toggled.connect(func(val): autosave_on = val)

	%SaveButton.pressed.connect(func(): _save(current_file))
	%LoadButton.pressed.connect(load_dialog.show)
	%SaveAsButton.pressed.connect(save_dialog.show)
	%GoBackButton.pressed.connect(
		func():
			get_tree().change_scene_to_file('res://recenti.tscn')
	)

	save_dialog.add_filter('*.csv', 'Valori separati da virgola')
	load_dialog.add_filter('*.csv', 'Valori separati da virgola')
	save_dialog.file_selected.connect(_on_file_selected)
	load_dialog.file_selected.connect(_load_file)
	save_dialog.current_file = current_file
	load_dialog.current_file = current_file
	
	$AutosaveTimer.timeout.connect(_autosave)
	
	%Cerca.text_changed.connect(_search)
	
	_load_file(current_file)

func _add_element():
	var new_element = Element.instantiate()
	$Panel/ScrollContainer/Elementi.add_child(new_element)
	return new_element

func _sort_button(key : String):
	%SortAttivo.text = key
	
	_sort(key)

func _sort(key : String):
	# Make an array of dicts from elements storing their value
	# Sort the array by the dict value and move the children according
	# to their position in the dict array
	var elements_children : = elements.get_children()
	var elements_dicts : Array[Dictionary] = []
	
	# Remove accents
	key = key.replace('à', 'a')
	key = key.replace('è', 'e')
	key = key.replace('ì', 'i')
	key = key.replace('ò', 'o')
	key = key.replace('ù', 'u')
	
	for child in elements_children:
		var value
		if child.get(key.to_lower()) is LineEdit:
			value = child.get(key.to_lower()).text
		else:
			value = child.get(key.to_lower()).get_value()
		
		var dict = {
			'node': child,
			'value': value
		}
		elements_dicts.append(dict)

	elements_dicts.sort_custom(_sort_element_by_value)
	
	for i in elements_dicts:
		print(i)
		i.node.move_to_front()

func _sort_element_by_value(a : Dictionary, b : Dictionary):
	return a.value < b.value


func _save(path : String, show_popup = true):
	print(path)

	var headers = PackedStringArray([])
	
	for child in %Ordini.get_children():
		var header = String(child.name).replace('Ordina', '')
		headers.append(header)

	var csv = CSVObject.new(headers)
	
	for element in elements.get_children():
		var row = PackedStringArray([])
		
		row.append_array([
			element.cognome.text,
			element.nome.text,
			element.indirizzo.text,
			str(element.cap.value),
			element.citta.text,
			str(element.municipalita.value),
			element.quartiere.text,
			element.telefono.text,
		])
		
		csv.add_row(headers, row)

	CSV.write_csv(path, csv)
	
	Globals.add_recent(path)
	
	if show_popup:
		%SavedPopup.show()

func _on_file_selected(path : String):
	current_file = path
	_save(current_file)


func _load_file(path : String):
	current_file = path
	Globals.add_recent(path)
	
	if not FileAccess.file_exists(path):
		return
	
	var csv = CSV.parse_csv(path)
	
	for node in elements.get_children():
		node.queue_free()
	
	for i in csv.length():
		var element = _add_element()
		element.set_from_row(
			csv.get_row(i)
		)
	


func _autosave():
	if autosave_on:
		_save(current_file, false)


func _search(new_text : String):
	var type : String = %SortAttivo.text.to_lower()
	
	if new_text == '':
		for element in elements.get_children():
			element.visible = true
		return
	
	for element in elements.get_children():
		var value_node = element.get(type)
		var content : String
		
		if value_node is LineEdit:
			content = value_node.text.to_lower()
		elif value_node is SpinBox:
			content = str(value_node.value).to_lower()
			
		element.visible = content.contains(new_text.to_lower())
