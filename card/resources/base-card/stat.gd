extends Resource
class_name Stat

@export var attribute:Attribute = StaticGlobals.DEFAULT_ATTRIBUTE:
	set = set_attribute

var key:String:
	get:
		return attribute.key

@export var value:= str(-1):
	set = set_value
@export var order:int = -1

func set_value(new_value:Variant) -> void:
	value = new_value

func set_attribute(new_attribute:Attribute) -> void:
	if new_attribute == StaticGlobals.DEFAULT_ATTRIBUTE:
		attribute = new_attribute
		return
	if attribute.key != new_attribute.key:
		attribute = new_attribute
		reset_value()

func reset_value():
	value = ""

func merge(other:Stat):
	if attribute.key != other.attribute.key:
		push_error("Cant merge Stats with different attributes!")
		return
	value += other.value

func add_int(delta:int, minimum_allowed:int = StaticGlobals.INT_MIN):
	value = str(max(int(value) + delta, minimum_allowed))


static func Sort(a:Stat,b:Stat) -> bool:
	var primary_sorting := a.order < b.order
	var same_prioriy := a.order - b.order == 0
	if not same_prioriy:
		return primary_sorting
	return Attribute.sort(a.attribute,b.attribute)

func _validate_property(property: Dictionary) -> void:
	if property.name == "attribute":
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_NEVER_DUPLICATE
