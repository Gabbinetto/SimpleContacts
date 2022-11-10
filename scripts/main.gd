extends CanvasLayer

const Element = preload('res://scenes/element.tscn')

signal added_element

var autosave_on : = true
var current_focused_node : ElementRow
var max_scroll_length : int
var ascending : = true
var categories_history : Array[String]

@onready var save_dialog : FileDialog = $SaveDialog
@onready var load_dialog : FileDialog = $LoadDialog
@onready var elements : VBoxContainer = $Panel/ScrollContainer/Elementi
@onready var scroll_container : ScrollContainer = elements.get_parent()
@onready var scrollbar : VScrollBar = scroll_container.get_v_scroll_bar()
@onready var settings_panel : Impostazioni = $Panel/PannelloImpostazioni
@onready var voci : HBoxContainer = $Panel/Voci

var current_file = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + '/SenzaNome.csv':
	set(value):
		current_file = value
		%Percorso.text = current_file

func _ready() -> void:
	current_file = Globals.path_to_pass
	
	%AscendDiscend.pressed.connect(
		func():
			ascending = not ascending
			%AscendDiscend.scale.y = 0.5 if not ascending else -0.5
			if %SortAttivo.text != '':
				_sort_button(%SortAttivo.text)
	)
	%AddButton.pressed.connect(_add_element)
	%Impostazioni.pressed.connect(func(): settings_panel.open())

	%AutosaveButton.toggled.connect(func(val): autosave_on = val)

	%SaveButton.pressed.connect(func(): _save(current_file))
	%LoadButton.pressed.connect(load_dialog.show)
	%SaveAsButton.pressed.connect(save_dialog.show)
	%GoBackButton.pressed.connect(
		func():
			current_file = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + '/SenzaNome.csv'
			get_tree().change_scene_to_file('res://scenes/recenti.tscn')
	)

	save_dialog.add_filter('*.csv', 'Valori separati da virgola')
	load_dialog.add_filter('*.csv', 'Valori separati da virgola')
	save_dialog.file_selected.connect(_on_file_selected)
	load_dialog.file_selected.connect(_load_file)
	
	$AutosaveTimer.timeout.connect(_autosave)
	$AutosaveTimer.start(settings_panel.get_autosave_time())
	
	%Cerca.text_changed.connect(_search)
	
	_load_file(current_file)
	
	get_viewport().gui_focus_changed.connect(
		func(node):
			if node.owner is ElementRow:
				current_focused_node = node.owner
			elif node.owner is Impostazioni:
				settings_panel.on_focus_changed.call(node)
	)
	
	added_element.connect(func():
		await get_tree().create_timer(0.07)
	)
	
	max_scroll_length = scrollbar.max_value
	scrollbar.changed.connect(func(): 
		if max_scroll_length != scrollbar.max_value:
			max_scroll_length = scrollbar.max_value
			scroll_container.scroll_vertical = max_scroll_length
			print(max_scroll_length, ' ', scroll_container.scroll_vertical)
	)
	
	settings_panel.closed.connect(_sync_settings)

func _add_element() -> ElementRow:
	var new_element : ElementRow = Element.instantiate()

	elements.add_child(new_element)
	
	
	for category in _get_current_categories():
		new_element.add_category(category)
	
	new_element.categories_container.get_child(0).grab_focus()
	
	current_focused_node = new_element
	
	added_element.emit()
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
		var category = child.categories.get(key)
		var value : String = category.text
		
		var dict = {
			'node': child,
			'value': value
		}
		elements_dicts.append(dict)

	elements_dicts.sort_custom(_sort_element_by_value)
	
	for i in elements_dicts:
		i.node.move_to_front()

func _sort_element_by_value(a : Dictionary, b : Dictionary):
	if ascending:
		return a.value < b.value
	else:
		return a.value > b.value

func _save(path : String, show_popup = true):
	var headers = PackedStringArray([])
	
	for child in voci.get_children():
		var header = String(child.name).replace('Ordina', '')
		headers.append(header)

	var csv = CSVObject.new(headers)
	
	for element in elements.get_children():
		var row = PackedStringArray([])
		
		element.update_categories()
		
		for category in element.categories.keys():
			row.append(element.categories[category].text)
		
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
	
	var csv : CSVObject = CSV.parse_csv(path)
	
	for node in elements.get_children():
		node.queue_free()
	
	for category in csv.categories.keys():
		_add_category(category)
		settings_panel.add_category(category)
	
	for i in csv.length():
		var element : ElementRow = await _add_element()
		element.set_from_row(
			csv.get_row(i), csv.categories.keys()
		)
		
		element.update_categories()
	
	categories_history = settings_panel.get_categories_names()
	
func _add_category(_name : String):
	var current_categories : = _get_current_categories()
	if _name in current_categories:
		return
	
	var button : = Button.new()
	button.name = _name
	button.text = _name
	button.size_flags_horizontal = button.SIZE_EXPAND_FILL
	button.pressed.connect(func(): _sort_button(_name))
	button.tooltip_text = _name
	voci.add_child(button)
	

	
	return button

func _autosave():
	if autosave_on:
		_save(current_file, false)
		$AutosaveTimer.start(settings_panel.get_autosave_time())


func _search(new_text : String):
	var type : String = %SortAttivo.text
	
	if new_text == '':
		for element in elements.get_children():
			element.visible = true
		return
	
	for element in elements.get_children():
		var value_node = element.categories.get(type)
		var content : String
		
		if value_node is LineEdit:
			content = value_node.text.to_lower()
		elif value_node is SpinBox:
			content = str(value_node.value).to_lower()
			
		element.visible = content.contains(new_text.to_lower())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_accept') and is_instance_valid(current_focused_node):
		var index = elements.get_children().find(current_focused_node)
		if index < (elements.get_children().size() - 1) and is_instance_valid(elements.get_child(index)):
			_move_element(1)
		else:
			var new : = _add_element()
			
	if event.is_action_pressed('ui_focus_down'):
		_move_element(1)
	elif event.is_action_pressed('ui_focus_up'):
		_move_element(-1)
	
		
func _move_element(offset : int):
		var elements_children : Array[Node] = elements.get_children()
		var current_index = elements_children.find(current_focused_node)
		if current_index != -1 and current_index < (elements_children.size()):
			var next = elements.get_child(current_index + offset)
			if is_instance_valid(next):
				next.get_first().grab_focus()

func _get_current_categories() -> Array[String]:
	var current_categories : Array[String] = []
	for node in voci.get_children():
		current_categories.append(String(node.name))
	return current_categories

func _sync_settings(categories : Array[Dictionary]):
	# Check deleted
	var olds = []
	for category in categories:
		olds.append(category.old)
	
	for node in voci.get_children():
		if node.text not in olds:
			for element in elements.get_children():
				element.categories_container.remove_child(element.categories[node.text])
				element.categories[node.text].queue_free()
				element.categories.erase(node.text)
			
			node.queue_free()
	
	for category in categories:
		# Check changes
		if category.old != category.new and category.old != null:
			var voce = voci.get_node_or_null(category.old)
			if voce == null:
				continue
			voce.name = category.new
			voce.text = category.new
			
			for element in elements.get_children():
				element.change_category_name(category.old, category.new)
		
		# Add new categories
		var current_categories = []
		for node in voci.get_children():
			current_categories.append(String(node.name))
		if category.new not in current_categories:
			_add_category(category.new)
			for element in elements.get_children():
				element.add_category(category.new)

		# Reorder
		voci.move_child(voci.get_node(category.new), category.index)
		for element in elements.get_children():
			element.categories_container.move_child(element.categories_container.get_node(category.new), category.index)

	_sort_button(voci.get_child(0).text)
