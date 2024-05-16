extends Resource
class_name AttributeCollection
signal cache_rebuilt

@export var items : Array[Attribute] = []:
	set(value):
		items = value
		_rebuild_cache(true)

var cache : Dictionary

func _get(property: StringName) -> Variant:
	if cache.has(property):
		return cache[property]
	return null

func _set(_property: StringName, _value: Variant) -> bool:
	push_error("Do not set an Attribute directly, modify the AttribueList resource")
	return false

func _rebuild_cache(force := false) -> void:
	if cache and not force:
		return
	cache = {}
	for item in items:
		if cache.has(item.key):
			push_error("Duplicate Key in Attributes Collection: '%s'" % item.key)
		cache[item.key] = item
	cache_rebuilt.emit()
