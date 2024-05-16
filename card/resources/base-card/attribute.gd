extends Resource
class_name Attribute

@export var key : StringName = "$default_key"
@export var name : String = "Default Attribute"
@export var icon : Texture = preload("res://assets/cards/misc/empty_image.tres")
@export var order : int = -1

static func sort(a:Attribute,b:Attribute) -> bool:
	return a.order < b.order


