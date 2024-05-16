extends PanelContainer

@export_category("Resources")
@export var skill : Skill = Skill.new()
@export var icons: Array[AttributeCollection]
@export_category("Fonts")
@export var font_size = 64
@export var title_font :Font = preload("res://card/resources/fonts/commando.ttf")
@export var description_font : Font = preload("res://card/resources/fonts/Alice-Regular.ttf")
@onready var ui_main_label :KeywordAwareRichTextLabel = %MainLabel

func _ready() -> void:
	ui_main_label.skill_icons = icons

func update():
	ui_main_label.clear()
	ui_main_label.skill_icons = icons
	update_type()
	update_name()
	update_description()

func update_type():
	ui_main_label.push_color(Color.ORANGE)
	ui_main_label.push_outline_size(3)
	ui_main_label.push_outline_color(Color.BLACK)
	ui_main_label.push_font(title_font)
	ui_main_label.push_font_size(font_size)
	ui_main_label.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	ui_main_label.push_keywords(skill.type)
	# Work-around for font not having the glyph Online for some reason.
	ui_main_label.push_font(description_font)
	ui_main_label.append_text(": ")

func update_name():
	ui_main_label.push_font(title_font)
	ui_main_label.push_color(Color.WHITE)
	ui_main_label.push_keywords(skill.name)

func update_description():
	ui_main_label.newline()
	ui_main_label.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	ui_main_label.push_color(Color.WHITE)
	ui_main_label.push_outline_color(Color.BLACK)
	ui_main_label.push_outline_size(1)
	ui_main_label.push_font(description_font)
	ui_main_label.push_keywords(skill.requirements)
