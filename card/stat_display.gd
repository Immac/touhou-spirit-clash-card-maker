extends Control
class_name SymbolCounter


@export var stat : Stat = Stat.new()
@export var label_size : int = 48
@export var cardinal_rotation := Util.Cardinal.UP

@onready var label : IconLabel = %Value
@onready var icon : TextureRect = %Icon

func _ready():
	update.call_deferred()

func update():
	if stat:
		icon.texture = stat.attribute.icon
		label.text = stat.value
		rotation = Util.CardinalToDegrees(cardinal_rotation)
		pivot_offset = size/2
		modulate = Color.WHITE if stat.get_meta("visible", true) else Color.TRANSPARENT
		label.modulate = Color.WHITE if stat.get_meta("value_visible",true) else Color.TRANSPARENT
