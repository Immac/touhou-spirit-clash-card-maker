extends RichTextLabel
class_name KeywordAwareRichTextLabel
@export var default_icon_size = 28
@export var skill_icons: Array[AttributeCollection]
@export var default_image_color: Color = Color.WHITE

var _is_cache_dirty := true
var _keyword_cache := {}

func _set(property, value) -> bool:
	if property == "text":
		parse_bbcode(replace_keyword_with_icon(value))
		return true
	return false

func _ready() -> void:
	property_list_changed.connect(update)
	for collection in skill_icons:
		collection.cache_rebuilt.connect(func(): _is_cache_dirty=true)
	update.call_deferred()

func update():
	_set("text", text)

func update_cache(force:=false) -> void:
	if _is_cache_dirty or force:
		_keyword_cache = {}
		for collection in skill_icons:
			collection.items.reduce(func(output: Dictionary, a: Attribute) -> Dictionary:
				if output.has(a.key):
					assert(false, "Symbol Key duplication found: %s in colleciton %s" % [a.key, collection.resource_name])
				output[a.key]=a
				return output
				, _keyword_cache)
		_is_cache_dirty = false

func replace_keyword_with_icon(input: String) -> String:
	var output = input
	for list in skill_icons:
		for item in list.items:
			var options = [
				["bg_color", item.get_meta("skill_bgcolor", Color.BLACK).to_html(true)],
				["size", item.get_meta("default_icon_size", default_icon_size)],
				["color", item.get_meta("skill_color", default_image_color).to_html(true)],
				["path", item.icon.resource_path]
			]
			var replacement_text = "[bgcolor={skill_bgcolor}][img width={size} color={color}]{path}[/img][/bgcolor]".format(options)
			output = output.replace(item.key, replacement_text)
	return output

const START_DELIMITER = "$"
const END_DELIMITER = "$"
func _prepare_input(input: String) -> Array:
	var output = []
	var current = StaticGlobals.EMPTY_STRING
	var in_keyword = false
	var escape_next = false

	for i in range(input.length()):
		var c = input[i]
		if escape_next:
			current += c
			escape_next = false
		elif c == "\\":
			escape_next = true
		elif c == START_DELIMITER and !in_keyword:
			if current != StaticGlobals.EMPTY_STRING:
				output.append(current)
			current = START_DELIMITER
			in_keyword = true
		elif c == END_DELIMITER and in_keyword:
			current += END_DELIMITER
			output.append(current)
			current = StaticGlobals.EMPTY_STRING
			in_keyword = false
		else:
			current += c
	if current != StaticGlobals.EMPTY_STRING:
		output.append(current)
	return output

func push_keywords(input: String) -> void:
	update_cache()
	var prepared_input = _prepare_input(input)
	for i in prepared_input:
		if _keyword_cache.has(i):
			var a: Attribute = _keyword_cache[i]
			var size_: int = a.get_meta("icon_size", default_icon_size)
			var color_: Color = a.get_meta("skill_color", default_image_color)
			var icon_ := a.icon
			add_image(icon_, size_, size_, color_)
		else:
			add_text(i)
