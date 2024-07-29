extends Node

var tiers_availible := {}
# "get_nameb" : [8,10,13]

var previously_performed_reactions : PackedStringArray = []
# "get_nameb + get_nameb"

var discovered : PackedStringArray = []
# "get_nameb"

var volatility : float = 0
#goes up if you perform a reaction out of shadow
#goes up if you move the cauldron

var move_count : int = 100
#goes down if you move the cauldron at 0 the cauldron will no longer move

var fusion_count : int = 0
var fusion_lim : int = 15
var total_fusion_count : int = 0
var duo_chance : float = 50

var in_shadow := false
var can_conjure := false
var conjure_level : int = 0
var can_interact := true

var boost_latin := false
var boost_greek := false
var consume_mod : float = 0

var player_name : String = "Yiev"
var player_shader : Material

var consumed_mixture : Mixture

var used_cheats := false
var cheat_no_sentinel := false
var cheat_no_move_count := false
#once on you can't submit your score without hard reseting the game

signal alchemy
signal wake_sent
signal sent_regen
signal sage_bounce
signal respawn_conjure #on third conjure press respawn happens, and sentinel might wake
signal move_shadows
signal rouse_shadows
signal tickle_shadows
signal clear_spirits
signal add_shadow
signal remove_shadow

signal open_cauldron
signal add_unit #aUnit
signal return_to_pool #node
signal force_close_cauldron
signal add_potion #mixture
signal remove_potion #mixture
signal eval_potion #bool mixture

var dragging
signal start_drag
signal stop_drag
signal dropped

signal finish_pop

signal fcam
signal zcam
signal smallnote

const AS = preload("res://Assets/AlloySynergy.tres")
#const MS = preload("res://Assets/MixtureSynergy.tres")
const MSB = preload("res://Assets/MixtureSynergyBase.tres")

func reset():
	tiers_availible.clear()
	previously_performed_reactions.clear()
	discovered.clear()
	volatility = 0
	move_count = 100
	fusion_count = 0
	fusion_lim = 10
	total_fusion_count = 0
	boost_latin = false
	boost_greek = false
	consume_mod = 0
	

func get_ms(w : int,h : int,d : int, seed_offset : int = 0) -> Array[Image]:
	var n2d : NoiseTexture2D
	var arr : Array[Image]
	for i in h:
		n2d = NoiseTexture2D.new()
		var noi = MSB.duplicate()
		noi.seed = round(i * TAU) + seed_offset
		#noi.offset = Vector3(w,d,i + seed_offset)
		n2d.noise = noi
		n2d.width = w
		n2d.height = h
		await n2d.changed
		arr.append(n2d.get_image())
	return arr
