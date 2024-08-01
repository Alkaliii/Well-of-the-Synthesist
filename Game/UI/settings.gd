extends Control

@onready var mstr = $pc/vbc/mstr
@onready var muse = $pc/vbc/muse
@onready var sfx = $pc/vbc/sfx

@onready var sc = $pc/vbc/sc
@onready var cheats = $pc/vbc/cheats

# Called when the node enters the scene tree for the first time.
func _ready():
	mstr.new_value.connect(set_master_volume)
	mstr.default = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	mstr.reset()
	muse.new_value.connect(set_music_volume)
	muse.default = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	muse.reset()
	sfx.new_value.connect(set_sfx_volume)
	sfx.default = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx")))
	sfx.reset()
	
	s.button_pressed = Global.cheat_no_sentinel
	mc.button_pressed = Global.cheat_no_move_count
	
	await get_tree().process_frame
	var c = get_tree().get_first_node_in_group("crt_eft")
	if c: 
		crtt.button_pressed = Global.crt_vis
		c.visible = crtt.button_pressed

func open():
	var effect : AudioEffect = AudioEffectLowPassFilter.new()
	effect.db = AudioEffectFilter.FILTER_24DB
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"),effect)
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"),1,true)
	show()

func close():
	AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"),1)
	hide()

func set_master_volume(v):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(v))

func set_music_volume(v):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear_to_db(v))

func set_sfx_volume(v):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"),linear_to_db(v))

func _on_sc_pressed():
	sc.release_focus()
	cheats.visible = !cheats.visible
	match cheats.visible:
		true: sc.text = "hide cheats"
		false: sc.text = "show cheats"

func _on_rstrt_pressed():
	close()
	if !SFXm.looping.is_empty():
		for l in SFXm.loop_paths:
			SFXm.stop_loop(l)
	Global.reset()
	get_tree().reload_current_scene()

func _on_ts_pressed():
	close()
	if !SFXm.looping.is_empty():
		for l in SFXm.loop_paths:
			SFXm.stop_loop(l)
	get_tree().get_first_node_in_group("ldr").loadnew("res://Game/title_screen.tscn")

@onready var s = $pc/vbc/cheats/s
func _on_s_toggled(toggled_on):
	s.release_focus()
	if toggled_on: Global.used_cheats = true
	Global.cheat_no_sentinel = toggled_on

@onready var mc = $pc/vbc/cheats/mc
func _on_mc_toggled(toggled_on):
	mc.release_focus()
	if toggled_on: Global.used_cheats = true
	Global.cheat_no_move_count = toggled_on

@onready var crtt = $pc/vbc/crtt
func _on_crtt_pressed():
	crtt.release_focus()
	var c = get_tree().get_first_node_in_group("crt_eft")
	Global.crt_vis = crtt.button_pressed
	if c: c.visible = crtt.button_pressed
