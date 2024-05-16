extends PanelContainer

@export var skill : Skill
@export var icons: Array[AttributeCollection]

@onready var ui_skill_box = %SkillBox

func _ready():
	ui_skill_box.skill = skill
	ui_skill_box.icons = icons
	ui_skill_box.update.call_deferred()

func update():
	ui_skill_box.update()
