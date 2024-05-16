class_name CardData
extends Resource

@export_group("Top")
@export var element: Stat = Stat.new()
@export var name := "Card Name"
@export var title := "Card Title"
@export var background_texture: Texture = preload ("res://assets/cards/background/yellow.png")
@export var upkeep: Stat = Stat.new()
@export_group("Middle")
@export var art: Texture = preload ("res://assets/cards/illustration/set-alpha/example-art.png")
@export var supply_generation: Array[Stat]
@export var tenacity_stats: Array[Stat]
@export_group("Bottom")
@export var flavor_text: String = "Once a mere echo in the aether, this entity awaits its true tale.
Replace this text with your own lore to breathe life into this card."
@export var skills: Array[Skill]
@export var spirit_stats: Array[Stat]
@export var combat_stats: Array[Stat]
@export var level: Stat = Stat.new()
@export var artist: String = "Artist Name"
@export var is_ai_asssited: bool = false
@export var series_name: String = "Series Name"
@export var card_id_in_series: int = 0
@export var year := 2024
@export var rarity: Attribute = Attribute.new()

#TODO: Make Spirit Stats a single Stat

func stat_is_over_zero (stat: Stat) -> bool:
	return int(stat.value) > 0
func stat_is_zero_or_higher (stat: Stat) -> bool:
	return int(stat.value) >= 0

func validate():
	#Card's Element and Spirit Cost
	set_visibility_thresholds(element, -2, -1)
	#Card's Stagger Recovery Cost
	set_visibility_thresholds(upkeep, -2, -1)
	#Spirit Generation
	for stat in spirit_stats:
		if int(stat.value) <= 0:
			stat.value = "0"
	# Tenacity
	tenacity_stats = tenacity_stats.filter(func(input:Stat):
		return int(input.value) > 0)

	spirit_stats = spirit_stats.filter(stat_is_over_zero)
	spirit_stats.sort_custom(Stat.Sort)
	spirit_stats.reverse()
	#Combat Stats
	combat_stats.sort_custom(Stat.Sort)
	combat_stats = combat_stats.filter(stat_is_zero_or_higher)
	for stat in combat_stats:
		set_visibility_thresholds(stat,-2,-1)

func set_visibility_thresholds(member: Stat, hide_stat_threshold: int, hide_value_threshold:int):
	var as_int: int = int(member.value)
	as_int = max(hide_stat_threshold, as_int)
	member.value = str(as_int)
	member.set_meta("visible", as_int > hide_stat_threshold)
	member.set_meta("value_visible", as_int > hide_value_threshold)

var cache := {}
func get_dictionary(stat_array: Array[Stat], key:="") -> Dictionary:
	if key == null or key.is_empty():
		return {}
	if cache.has(key):
		return cache[key]
	var output := {}
	for stat in stat_array:
		pass
	cache[key] = output
	return output

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"background_texture", "art", "rarity":
			property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_NEVER_DUPLICATE
