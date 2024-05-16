class_name MakerSkillEditor
extends MarginContainer
signal skill_changed

var skill_list : Array[Skill] = []:
	set(new_value):
		assert(new_value != null, "skill_list, can't be null")
		if new_value == skill_list:
			return
		skill_list = new_value

func _ready() -> void:
	sync_ui()

const MAKER_SKILL_ITEM = preload("res://tools/maker_skill_item.tscn")
@onready var ui_skills_container: TabContainer = %"Skills Container"
func sync_ui():
	for child in ui_skills_container.get_children():
		ui_skills_container.remove_child(child)
		child.queue_free()
	for skill in skill_list:
		var ui_skill := MAKER_SKILL_ITEM.instantiate()
		ui_skill.name = skill.name
		ui_skill.skill = skill
		ui_skills_container.add_child(ui_skill)
		ui_skill.skill_changed.connect(_a_skill_changed)

func _a_skill_changed():
	skill_changed.emit()

func _on_new_skill_pressed() -> void:
	randomize()
	var new_skill = Skill.new()
	new_skill.name += " " + str(randi())
	skill_list.push_back(new_skill)
	skill_changed.emit()
	sync_ui()

@onready var ui_remove_confirmation: ConfirmationDialog = %"Remove Confirmation"
@onready var ui_nothing_to_remove: AcceptDialog = %"Nothing to Remove"

func _on_remove_skill_button_pressed() -> void:
	if skill_list.size() > 0:
		ui_remove_confirmation.popup_centered()
	else:
		ui_nothing_to_remove.popup_centered()

func _on_remove_confirmation_confirmed() -> void:
	if skill_list.size() > 0:
		skill_list.remove_at(ui_skills_container.current_tab)
		skill_changed.emit()
		sync_ui()

func _on_skills_container_tab_selected(_tab: int) -> void:
	get_tree().call_group("Skill Pop Ups","close_items_pop_up")
