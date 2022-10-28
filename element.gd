extends Panel

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
