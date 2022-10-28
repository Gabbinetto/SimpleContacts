extends Node
class_name CSV 

static func parse_csv(path : String) -> CSVObject:
	var file = FileAccess.open(path, FileAccess.READ)
	
	var headers : = file.get_csv_line()
	print(headers)
	var csv_object : = CSVObject.new(headers)

	while !file.eof_reached():
		var line = file.get_csv_line()
		for i in line.size():
			csv_object.add_value(headers[i], line[i])
			
	return csv_object

static func write_csv(path : String, csv : CSVObject):
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	file.store_csv_line(csv.categories.keys())
	
	for i in csv.length():
		file.store_csv_line(
			csv.get_row(i)
		)
	
	print(file.file_exists(path))
