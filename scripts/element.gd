extends Panel
class_name ElementRow

@onready var categories_container : = $Categories
@onready var delete_button : = $DeleteButton

var categories : Dictionary = {}

func _ready() -> void:
	delete_button.pressed.connect(queue_free)
	
	if is_instance_valid(get_first()):
		get_first().grab_focus()

#func _format_cellphone(new_number : String):
#	if new_number.length() == 10:
#		telefono.text = new_number.substr(0, 3) + ' ' + new_number.substr(3, 3) + ' ' + new_number.substr(6)

func set_from_row(row : PackedStringArray, headers : PackedStringArray):
	for node in categories_container.get_children():
		node.queue_free()
		categories_container.remove_child(node)
	update_categories()
	
	for i in headers.size():
		var category : = add_category(
			headers[i]
		)
		category.text = row[i]
	
	sync_all_tooltip()

func add_category(_name : String) -> LineEdit:
#	if _name in categories.keys():
#		categories.get(_name).queue_free()
#		categories.erase(_name)

	var already_existing : = categories_container.get_node_or_null(_name)
	if is_instance_valid(already_existing):
		return

	var category = LineEdit.new()
	category.name = _name
	category.placeholder_text = _name
	category.size_flags_horizontal = category.SIZE_EXPAND_FILL
	category.text_changed.connect(
		func(_new_text): sync_all_tooltip()
	)

	categories_container.add_child(category)
	category.set_owner(self)
	
	update_categories()
	
	return category


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_cut'):
		add_category(str(randi() % 200))

func get_first() -> LineEdit:
	return categories.get(categories.keys().front())

func _sync_tooltip(node : LineEdit):
	node.tooltip_text = node.text

func sync_all_tooltip():
	for node in categories_container.get_children():
		_sync_tooltip(node)

func update_categories():
#	print(categories)
	categories = {}
#	print(categories)
	for node in categories_container.get_children():
		categories[node.name] = node


func change_category_name(category : String, new_name : String):
	categories[new_name] = categories[category]
	categories.erase(category)
	
	categories[new_name].name = new_name
	categories[new_name].placeholder_text = new_name
