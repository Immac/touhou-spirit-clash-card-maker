extends ItemList
class_name AttributeItemList

@export_category("Resources")
@export var ad_hoc_items : Array[Attribute]
@export var resource_list: AttributeCollection
@export var clear_item_list_item : Attribute = preload("res://database/attributes/ui/clear.tres")
@export var select_first_by_default := false

var _cache := {}

const MouseButtonFlags :Dictionary ={MOUSE_BUTTON_LEFT:0x1,
MOUSE_BUTTON_RIGHT:0x2,
MOUSE_BUTTON_WHEEL_DOWN:0x4,
MOUSE_BUTTON_WHEEL_UP:0x4,
MOUSE_BUTTON_MIDDLE:0x8}

@export_flags("Left Mouse Button:%d" % MouseButtonFlags[MOUSE_BUTTON_LEFT],
"Right Mouse Button:%d" % MouseButtonFlags[MOUSE_BUTTON_RIGHT],
"Mouse Scroll:%d" % (MouseButtonFlags[MOUSE_BUTTON_WHEEL_DOWN] | MouseButtonFlags[MOUSE_BUTTON_WHEEL_UP]),
"Middle Mouse Button:%d" % MouseButtonFlags[MOUSE_BUTTON_MIDDLE]) \
var accepted_mouse_buttons = MouseButtonFlags[MOUSE_BUTTON_LEFT]

func _ready() -> void:
	init()

func init():
	if resource_list:
		clear()
		_generate_items(resource_list.items)
	if ad_hoc_items:
		_generate_items(ad_hoc_items)
	if select_first_by_default:
		select(0)

func _generate_items(array:Array[Attribute]) -> void:
	for item in array:
		add_item(item.name,item.icon)
		set_item_metadata(-1,item)
		_cache[item.key] = item
		_cache[item.key].set_meta("index",item_count - 1)

func _on_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if MouseButtonFlags.has(mouse_button_index) && MouseButtonFlags[mouse_button_index] & accepted_mouse_buttons != 0:
		select(index)

func select_by_key(key:String) -> bool:
	if not _cache.has(key):
		return false
	if not _cache[key].has_meta("index"):
		return false
	var index = _cache[key].get_meta("index")
	select(index)
	return true
