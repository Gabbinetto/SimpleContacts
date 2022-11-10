extends Resource
class_name  CSVObject

var categories : Dictionary = {}

func _init(headers : PackedStringArray) -> void:
	for header in headers:
		categories[header] = PackedStringArray([])

func add_value(header : String, value : String):
	categories[header].append(value)

func print_to_console():
	for category in categories:
		print(category, ': ')
		for value in categories[category]:
			print('- ', value)

func get_row(index : int) -> PackedStringArray:
	var row : = PackedStringArray([])
	
	for key in categories:
		if categories[key].size() - 1 < index:
			row.append('')
		else:
			row.append(categories[key][index])
	
	return row

func add_row(headers : PackedStringArray, values : PackedStringArray):
	for i in headers.size():
		categories[headers[i]].append(values[i])

func length() -> int:
	var _length : = 0

	for key in categories:
		var key_length = categories[key].size()
		if key_length > _length:
			_length = key_length

	return _length
