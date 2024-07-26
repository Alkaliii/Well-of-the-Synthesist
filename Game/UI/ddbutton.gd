extends Button
class_name ddButton

signal selected

func _ready():
	pressed.connect(select)

func select():
	selected.emit(self)
