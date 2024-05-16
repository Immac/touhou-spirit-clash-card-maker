extends VBoxContainer

signal skill_changed
var skill := Skill.new()

@onready var ui_type_text: LineEdit = %"Type Text"
@onready var ui_name_text: LineEdit = %"Name Text"
@onready var ui_skill_text: TextEdit = %"Skill Text"
@onready var pop_up: Window = %PopUp

static func FromSkill(skill_:Skill):
	var out = new()
	out.skill = skill_
	out.name = skill_.name
	return out

func update_ui():
	ui_type_text.text = skill.type
	ui_name_text.text = skill.name
	ui_skill_text.text = skill.requirements

func _ready() -> void:
	update_ui()
	ui_name_text.text_changed.connect(_skill_changed)
	ui_type_text.text_changed.connect(_skill_changed)
	ui_skill_text.text_changed.connect(_skill_changed)

func _skill_changed(_string:=""):
	skill.type = ui_type_text.text
	skill.name = ui_name_text.text
	if ui_name_text.text != StaticGlobals.EMPTY_STRING:
		name = ui_name_text.text
	skill.requirements = ui_skill_text.text
	skill_changed.emit()

func _on_icons_button_pressed() -> void:
	pop_up.popup_centered()
	pop_up.position.x = 16

@onready var nothing_selected: AcceptDialog = %"Nothing Selected"
@onready var maker_item_list: AttributeItemList = %MakerItemList
func _on_add_to_type_pressed() -> void:
	if  maker_item_list.get_selected_items().size() > 0:
		var selected = maker_item_list.get_selected_items()
		skill.type += maker_item_list.get_item_metadata(selected[0]).key
		ui_type_text.text += maker_item_list.get_item_metadata(selected[0]).key
		skill_changed.emit()
	else:
		nothing_selected.popup_centered()

func _on_add_to_name_pressed() -> void:
	if maker_item_list.get_selected_items().size() > 0:
		var selected = maker_item_list.get_selected_items()
		skill.name += maker_item_list.get_item_metadata(selected[0]).key
		ui_name_text.text += maker_item_list.get_item_metadata(selected[0]).key
		skill_changed.emit()
	else:
		nothing_selected.popup_centered()

func _on_add_to_effect_pressed() -> void:
	if  maker_item_list.get_selected_items().size() > 0:
		var selected = maker_item_list.get_selected_items()
		skill.requirements += maker_item_list.get_item_metadata(selected[0]).key
		ui_skill_text.text += maker_item_list.get_item_metadata(selected[0]).key
		skill_changed.emit()
	else:
		nothing_selected.popup_centered()

func close_items_pop_up():
	pop_up.visible = false

@onready var categories: MenuBar = %Categories
func _on_popup_menu_index_pressed(index: int) -> void:
	var x = categories.get_menu_popup(0).get_item_metadata(index)
	maker_item_list.resource_list = x
	maker_item_list.init()
