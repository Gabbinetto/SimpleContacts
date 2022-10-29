extends Panel
class_name ElementRow

@onready var cognome : LineEdit = $Categories/Cognome
@onready var nome : LineEdit = $Categories/Nome
@onready var indirizzo : LineEdit = $Categories/Indirizzo
@onready var cap : SpinBox = $Categories/CAP
@onready var citta : LineEdit = $Categories/SiglaCitta
@onready var municipalita : SpinBox = $Categories/Municipalita
@onready var quartiere : LineEdit = $Categories/Quartiere
@onready var telefono : LineEdit = $Categories/Telefono
@onready var delete_button : = $DeleteButton

func _ready() -> void:
	delete_button.pressed.connect(queue_free)
	cap.update_on_text_changed = true
	
	telefono.text_changed.connect(_format_cellphone)
	_format_cellphone(telefono.text)
	
	cognome.text_changed.connect(func(_unused): _sync_tooltip(cognome))
	nome.text_changed.connect(func(_unused): _sync_tooltip(nome))
	indirizzo.text_changed.connect(func(_unused): _sync_tooltip(indirizzo))
	cap.value_changed.connect(func(_unused): _sync_tooltip(cap))
	citta.text_changed.connect(func(_unused): _sync_tooltip(citta))
	municipalita.value_changed.connect(func(_unused): _sync_tooltip(municipalita))
	quartiere.text_changed.connect(func(_unused): _sync_tooltip(quartiere))
	telefono.text_changed.connect(func(_unused): _sync_tooltip(telefono))

func _format_cellphone(new_number : String):
	if new_number.length() == 10:
		telefono.text = new_number.substr(0, 3) + ' ' + new_number.substr(3, 3) + ' ' + new_number.substr(6)

func set_from_row(row : PackedStringArray):
	
	assert(row.size() >= 7)
	
	cognome.text = row[0]
	nome.text = row[1]
	indirizzo.text = row[2]
	cap.value = row[3].to_int()
	citta.text = row[4]
	municipalita.value = row[5].to_int()
	quartiere.text = row[6]
	telefono.text = row[7]

func is_focused():
	return cognome.has_focus() or nome.has_focus() or indirizzo.has_focus() or \
		cap.has_focus() or citta.has_focus() or municipalita.has_focus() or quartiere.has_focus() or telefono.has_focus()

func get_focused():
	if cognome.has_focus():
		return 'cognome'
	if nome.has_focus():
		return 'nome'
	if indirizzo.has_focus():
		return 'indirizzo'
	if cap.has_focus():
		return 'cap'
	if citta.has_focus():
		return 'citta'
	if municipalita.has_focus():
		return 'municipalita'
	if quartiere.has_focus():
		return 'quartiere'
	if telefono.has_focus():
		return 'telefono'
	
	return 'cognome'


func _sync_tooltip(node : Control):
	node.tooltip_text = node.text if node is LineEdit else node.value
