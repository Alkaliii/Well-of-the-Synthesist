extends Node3D

var gazing := false
var chances := 3

@onready var eye = $watcherbody/Eye
var msgbox : msgbx

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.alchemy.connect(on_alchemy)
	Global.move_shadows.connect(change_gaze)
	Global.rouse_shadows.connect(question_mixture)
	Global.wake_sent.connect(wake)
	Global.sent_regen.connect(regen)
	update_gaze()
	await get_tree().process_frame
	msgbox = get_tree().get_first_node_in_group("msgbox")

func regen():
	chances = clamp(chances + 1,0,4)

func change_gaze():
	if [true,false].pick_random():
		gazing = true
		update_gaze()

func wake():
	gazing = true
	update_gaze()

func question_mixture():
	if gazing:
		Global.fcam.emit(global_position)
		msgbox.position.y = -125
		await get_tree().create_timer(0.25).timeout
		var rm = ["Where did you get that?","Was that an elixir you just poured out?","Are you testing me?",
		"The darkness is not your friend.","..."]
		await msgbox.play_msg(rm.pick_random())
		await get_tree().create_timer(0.25).timeout
		Global.fcam.emit(Vector3.ZERO)

func on_alchemy():
	if in_area and !gazing:
		gazing = true
		update_gaze()
	if gazing:
		Global.can_interact = false
		if chances != 0:
			Global.force_close_cauldron.emit()
			Global.fcam.emit(global_position)
			msgbox.position.y = -125
			await get_tree().create_timer(0.5).timeout
			match chances:
				2: await msgbox.play_msg("[shake]Stop using that cauldron.")
				1: 
					await msgbox.play_msg("...")
					await msgbox.play_msg("Have you no ears?")
				3,_: await msgbox.play_msg("[shake]Do not use that cauldron.")
			await get_tree().create_timer(0.5).timeout
			Global.fcam.emit(Vector3.ZERO)
			chances -= 1
			if in_area:
				gazing = false
				update_gaze()
		else:
			Global.force_close_cauldron.emit()
			Global.fcam.emit(global_position)
			msgbox.position.y = -125
			await get_tree().create_timer(0.5).timeout
			await msgbox.play_msg("That's it.")
			await msgbox.play_msg("You end here.")
			await get_tree().create_timer(0.25).timeout
			get_tree().get_first_node_in_group("ldr").loadnew("res://Game/title_screen.tscn")
		Global.can_interact = true

var in_area := false
func _on_area_3d_body_entered(body):
	if "in_shadow" in body:
		handle_cauldron()
		in_area = true

func _on_area_3d_body_exited(body):
	if "in_shadow" in body:
		in_area = false

var handling := false
func handle_cauldron():
	if handling or !gazing: return
	handling = true
	#Global.force_close_cauldron.emit()
	#await get_tree().process_frame
	match [0,1,2].pick_random():
		0 when Global.total_fusion_count < 15:
			Global.fcam.emit(global_position)
			msgbox.position.y = -125
			await get_tree().create_timer(0.5).timeout
			await msgbox.play_msg("hmm...",1.5)
			await msgbox.play_msg("Good, now leave this place.",2.25)
		0:
			Global.fcam.emit(global_position)
			msgbox.position.y = -125
			await get_tree().create_timer(0.5).timeout
			await msgbox.play_msg("hmm...",1.5)
		1:
			pass
		2 when Global.total_fusion_count < 15:
			pass
		2:
			Global.fcam.emit(global_position)
			msgbox.position.y = -125
			await get_tree().create_timer(0.5).timeout
			await msgbox.play_msg("...",1.5)
			await msgbox.play_msg("Did you use this?",2.25)
	Global.smallnote.emit("the [color=white]sentinel[/color] ceased it's senses.")
	await get_tree().create_timer(0.25).timeout
	Global.fcam.emit(Vector3.ZERO)
	gazing = false
	update_gaze()
	handling = false

var old_gaze
func update_gaze():
	if gazing == old_gaze: return
	old_gaze = gazing
	match gazing:
		true:
			eye.texture.region = Rect2(0,0,180,108)
			SFXm.play("res://Assets/Sounds/387533__soundwarf__alert-short.wav","master",randf_range(0.9,1.1))
			await get_tree().create_timer(2.5).timeout
			Global.smallnote.emit("do not perform alchemy while the [color=white]sentinel[/color] gazes.")
		false:
			eye.texture.region = Rect2(180,0,180,108)
