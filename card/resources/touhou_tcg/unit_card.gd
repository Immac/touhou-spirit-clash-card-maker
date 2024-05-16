class_name UnitCard
extends Resource

var name:String
var title:String
var race:String
var occupation:String
var flavor_text:String
var effect_box_text:String
var inverted_effect_box_text:String
var inverted_text_box:String = "Stage Objective"

var play_cost:Stat
var stagger_recovery_cost:Stat
var support_stats:Dictionary
var spirit_generated:Dictionary

var hand_to_hand:Stat
var danmaku:Stat
var other_offensive_stats:Dictionary

var lives:Stat
var bombs:Stat
var block:Stat
var other_tenacity_stats:Dictionary

func to_card_data() -> CardData:
    return CardData.new()
