extends Control

@export var use_search := true

@onready var cauldron_drop_zone = $DropZone
@onready var particlecont = $particlecont
@onready var alloycont = $alloycont
@onready var rd = $ReadoutOptions/VBoxContainer/rd
@onready var clear = $ReadoutOptions/VBoxContainer/options/clear
@onready var synth = $ReadoutOptions/VBoxContainer/options/synth
@onready var decay = $ReadoutOptions/VBoxContainer/options/decay
@onready var echo = $ReadoutOptions/VBoxContainer/options/echo
@onready var twkiso_a = $ReadoutOptions/HBoxContainer/twkisoA
@onready var twkiso_b = $ReadoutOptions/HBoxContainer/twkisoB
@onready var isoslider_a = $ReadoutOptions/HBoxContainer/twkisoA/isosliderA
@onready var isoslider_b = $ReadoutOptions/HBoxContainer/twkisoB/isosliderB
@onready var detail_a = $ReadoutOptions/HBoxContainer/twkisoA/detailA
@onready var detail_b = $ReadoutOptions/HBoxContainer/twkisoB/detailB
@onready var search_dropdown_a = $HBoxContainer/SearchDropdownA
@onready var search_dropdown_b = $HBoxContainer/SearchDropdownB
@onready var detail = $ReadoutOptions/VBoxContainer/detail

var inside : Array[aUnit] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	cauldron_drop_zone.react_to_drag = true #set on UI open/close
	cauldron_drop_zone.dropped_here.connect(plop)
	handle_is_snap.set_iso.connect(set_isotope)
	search_dropdown_a.set_iso.connect(search_set_isoa)
	search_dropdown_b.set_iso.connect(search_set_isob)
	#await get_tree().process_frame
	#await particlecont.phill()
	#await alloycont.phill()
	update_readout()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_a():
	particlecont.add_unit_to_cont(Element.get_random(Vector2i(0,0)))

const psfx = ["res://Assets/Sounds/plobcutb.wav", "res://Assets/Sounds/plopcatc.wav", "res://Assets/Sounds/plopcut.wav"]
func plop(): #like the sound water goes when you drop ice in it lol
	if inside.size() == 2: return
	var ice = Global.dragging
	#clear global?
	if ice is aUnit: #do stuff
		print("Recived ",ice.get_name())
		SFXm.play(psfx.pick_random(),"master",randf_range(0.9,1.1))
		
		if Global.tiers_availible.has(ice.get_nameb()):
			var ta = Global.tiers_availible[ice.get_nameb()]
			var new = aUnit.clone(ice)
			new.tier = ta[ta.size() - 1]
			ice = new
		
		inside.append(ice)
		update_readout()
		if inside.size() == 2:
			await get_tree().process_frame
			cauldron_drop_zone.fhide()
			cauldron_drop_zone.react_to_drag = false

#@onready var notifier = $Notifier
#@onready var newdisc = $Notifier/VBoxContainer/newdisc
#@onready var nddetail = $Notifier/VBoxContainer/nddetail
#@onready var burst = $Notifier/burst
#var ntw : Tween
#var nddt = [
	#"has bloomed from the ether",
	#"emerged from the void",
	#"rose out of the abyss",
	#"concentrated into existance",
	#"bent space and time to appear here",
	#"collidied into this reality",
	#"burst through the ninth gate",
	#"has fallen into position",
	#"arrived in honor",
	#"slipped past the gatekeepers",
	#"popped into place"
#]
func notify_new_disc(new_name : String,rxp):
	var mdn = get_tree().get_first_node_in_group("mdn")
	mdn.notify_new_disc(new_name,rxp)
	#greek, no iso
	#if ntw: ntw.kill()
	#ntw = create_tween()
	#var pxsrt = get_tree().get_first_node_in_group("pxsort")
	#newdisc.text = str("[center][pulse][wave]",new_name)
	#nddetail.text = str("[center]",nddt.pick_random())
	#nddetail.visible_ratio = 0
	#ntw.tween_property(notifier,"position:y",96,0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#ntw.parallel().tween_property(pxsrt.material,"shader_parameter/sort",randf_range(1.2,2),0.2).set_ease(Tween.EASE_IN_OUT)
	#ntw.tween_property(pxsrt.material,"shader_parameter/sort",0.0,0.2).set_ease(Tween.EASE_IN_OUT)
	#ntw.parallel().tween_property(nddetail,"visible_ratio",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(0.5)
	#
	#await ntw.finished
	#burst.emitting = true
	#var n = str("you performed [color=ff3399]",rxp,"[/color], congrats on the new discovery")
	#Global.smallnote.emit(n)
	#ntw = create_tween()
	#ntw.tween_property(notifier,"position:y",-96,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(2)

@onready var readout_options = $ReadoutOptions
var twbro : Tween
var previous_rd : int = 0
func update_readout():
	match inside.size():
		0: 
			previous_rd = 0
			if twbro: twbro.kill()
			twbro = create_tween()
			twbro.tween_property(readout_options,"modulate:a",0,0.25).set_ease(Tween.EASE_IN_OUT)
			rd.text = "[center]?"
			clear.size_flags_horizontal = SIZE_FILL
			synth.hide()
			decay.hide()
			clear.hide()
			echo.hide()
			detail.text = ""
			if !use_search: disp_isosliders(0)
			else: disp_search(0)
		1: 
			previous_rd = 1
			if twbro: twbro.kill()
			twbro = create_tween()
			twbro.tween_property(readout_options,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
			rd.text = str("[center]",inside[0].get_namegb(true))
			clear.size_flags_horizontal = SIZE_FILL
			synth.hide()
			decay.show()
			clear.show()
			echo.show()
			detail.text = ""
			if !use_search: disp_isosliders(1)
			else: disp_search(1)
		2: 
			if previous_rd != 2:
				if twbro: twbro.kill()
				twbro = create_tween()
				twbro.tween_property(readout_options,"modulate:a",0.6,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
				twbro.tween_property(readout_options,"modulate:a",1,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			previous_rd = 2
			if Global.previously_performed_reactions.has(get_ordr()):
				var result = Alchemy.new().perform_reaction(inside[0],inside[1])
				rd.text = str("[center][color=#8a9399]",inside[0].get_namegb(true)," + ",inside[1].get_namegb(true)," [wave]==[/wave] ",result.get_namegb(true))
				clear.size_flags_horizontal = SIZE_EXPAND_FILL
				synth.size_flags_horizontal = SIZE_FILL
				synth.text = "synth"
				detail.text = "[center]Previously Performed"
			else:
				#print("don't have ",get_ordr())
				rd.text = str("[center]",inside[0].get_namegb(true)," + ",inside[1].get_namegb(true)," [wave]>>>[/wave] ?")
				synth.size_flags_horizontal = SIZE_EXPAND_FILL
				clear.size_flags_horizontal = SIZE_FILL
				synth.text = "synthesize"
				detail.text = ""
			synth.show()
			decay.hide()
			clear.show()
			echo.hide()
			if !use_search: disp_isosliders(2)
			else: disp_search(2)

func disp_search(z : int):
	match z:
		0:
			search_dropdown_a.hide()
			search_dropdown_a.current = ""
			search_dropdown_b.hide()
			search_dropdown_b.current = ""
		1:
			if Global.tiers_availible.has(inside[0].get_nameb()):
				search_dropdown_a.setmeup(inside[0].get_nameb())
				search_dropdown_a.show()
			else: search_dropdown_a.hide()
			search_dropdown_b.hide()
		2:
			if Global.tiers_availible.has(inside[0].get_nameb()):
				search_dropdown_a.setmeup(inside[0].get_nameb())
				search_dropdown_a.show()
			else: search_dropdown_a.hide()
			
			if Global.tiers_availible.has(inside[1].get_nameb()):
				search_dropdown_b.setmeup(inside[1].get_nameb())
				search_dropdown_b.show()
			else: search_dropdown_b.hide()

@onready var handle_is_snap = $ReadoutOptions/HBoxContainer/HandleISSnap
func disp_isosliders(z : int):
	match z:
		0:
			twkiso_a.hide()
			twkiso_b.hide()
		1:
			if Global.tiers_availible.has(inside[0].get_nameb()):
				detail_a.text = str(inside[0].get_nameg()," Isotope")
				handle_is_snap.afor = inside[0].get_nameb()
				var ta : PackedInt32Array = Global.tiers_availible[inside[0].get_nameb()]
				isoslider_a.max_value = ta[ta.size() - 1]
				isoslider_a.min_value = 0
				isoslider_a.value = inside[0].tier
				twkiso_a.show()
			else:
				twkiso_a.hide()
			twkiso_b.hide()
		2:
			if Global.tiers_availible.has(inside[0].get_nameb()):
				detail_a.text = str(inside[0].get_nameg()," Isotope")
				handle_is_snap.afor = inside[0].get_nameb()
				var ta : PackedInt32Array = Global.tiers_availible[inside[0].get_nameb()]
				isoslider_a.max_value = ta[ta.size() - 1]
				isoslider_a.min_value = 0
				isoslider_a.value = inside[0].tier
				twkiso_a.show()
			else:
				twkiso_a.hide()
			
			if Global.tiers_availible.has(inside[1].get_nameb()):
				detail_b.text = str("[right]",inside[1].get_nameg()," Isotope")
				handle_is_snap.bfor = inside[1].get_nameb()
				var ta : PackedInt32Array = Global.tiers_availible[inside[1].get_nameb()]
				isoslider_b.max_value = ta[ta.size() - 1]
				isoslider_b.min_value = 0
				isoslider_b.value = inside[1].tier
				twkiso_b.show()
			else:
				twkiso_b.hide()

func _on_echo_pressed():
	echo.release_focus()
	SFXm.play(psfx.pick_random(),"master",randf_range(0.9,1.1))
	inside.append(aUnit.clone(inside[0]))
	update_readout()
	await get_tree().process_frame
	cauldron_drop_zone.fhide()
	cauldron_drop_zone.react_to_drag = false

func _on_clear_pressed():
	inside.clear()
	cauldron_drop_zone.react_to_drag = true
	update_readout()
	clear.release_focus()

func _on_decay_pressed():
	decay.release_focus()
	
	var calc = Alchemy.new()
	set_isotope()
	if calc.can_dk(inside[0]):
		#Do math
		if Global.in_shadow and [true,false].pick_random():
			set_fc()
			inside.clear()
			update_readout()
			cauldron_drop_zone.react_to_drag = true
			SFXm.play("res://Assets/Sounds/error_006.ogg","master",randf_range(0.9,1.1))
			var n = str("[color=e62200]decay failed[/color], move the cauldron out of shadow.")
			Global.volatility += randf_range(0.05,0.2)
			Global.smallnote.emit(n)
			return
		
		var new = calc.perform_decay(inside[0],!Global.in_shadow)
		set_ta(new)
		var rxp = str(calc.rx.keys()[calc.reaction_performed]).to_lower().replace("_"," ")
		if !Global.discovered.has(new.get_nameb()):
			notify_new_disc(new.get_nameg(true),rxp)
		else:
			var n = str("[color=white]",rxp,"[/color], output was not notable.")
			Global.smallnote.emit(n)
		
		set_fc()
		
		if new is Alloy: 
			alloycont.add_unit_to_cont(new)
		if new is Element: 
			particlecont.add_unit_to_cont(new)
		inside.clear()
		update_readout()
		cauldron_drop_zone.react_to_drag = true
	else:
		SFXm.play("res://Assets/Sounds/error_006.ogg","master",randf_range(0.9,1.1))
		var n = str("[color=e62200]decay failed[/color]")
		Global.smallnote.emit(n)

func _on_synth_pressed():
	synth.release_focus()
	var calc = Alchemy.new()
	set_isotope()
	if calc.can_pr(inside[0],inside[1]):
		#Do math
		var new = calc.perform_reaction(inside[0],inside[1])
		
		set_ppr()
		
		#rd.text = str("[center]",new.get_nameg(true))
		if new is aUnit: set_ta(new)
		var rxp = str(calc.rx.keys()[calc.reaction_performed]).to_lower().replace("_"," ")
		if !Global.discovered.has(new.get_nameb()):
			notify_new_disc(new.get_nameg(true),rxp)
		elif new is aUnit:
			var n = str("[color=white]",rxp,"[/color], output was not notable.")
			Global.smallnote.emit(n)
		
		set_fc()
		
		if new is Alloy: 
			alloycont.add_unit_to_cont(new)
			if !Global.in_shadow: Global.volatility += randf_range(0.05,0.2)
			if [true,false,false].pick_random() and Global.fusion_count < Global.fusion_lim: Global.wake_sent.emit()
		if new is Element: 
			particlecont.add_unit_to_cont(new)
			if !Global.in_shadow: Global.volatility += randf_range(0.05,0.2)
			if [true,false,false,false].pick_random() and Global.fusion_count < Global.fusion_lim: Global.wake_sent.emit()
		if new is Mixture:
			var phb = get_tree().get_first_node_in_group("phb")
			if phb.in_hotbar.size() != 4:
				Global.add_potion.emit(new)
				if Global.discovered.has(new.get_nameb()):
					var n = str("[color=white]",rxp,"[/color], output was not notable.")
					Global.smallnote.emit(n)
			else:
				SFXm.play("res://Assets/Sounds/error_006.ogg","master",randf_range(0.9,1.1))
				var n = str("You can only hold [color=white]4[/color] mixtures at once. Please dispose.")
				Global.smallnote.emit(n)
			if [true,false].pick_random() and Global.fusion_count < Global.fusion_lim: Global.wake_sent.emit()
		inside.clear()
		update_readout()
		if range(26).pick_random() == 3: Global.tickle_shadows.emit()
		cauldron_drop_zone.react_to_drag = true
	pass # Replace with function body.

func search_set_isoa(nv):
	if search_dropdown_a.visible:
		var n = aUnit.clone(inside[0])
		n.tier = nv
		inside[0] = n
	update_readout()

func search_set_isob(nv):
	if search_dropdown_b.visible:
		var n = aUnit.clone(inside[1])
		n.tier = nv
		inside[1] = n
	update_readout()

func set_isotope(urd := false):
	if twkiso_a.visible:
		var n = aUnit.clone(inside[0])
		n.tier = handle_is_snap.slidera.value
		inside[0] = n
	
	if twkiso_b.visible:
		var n = aUnit.clone(inside[1])
		n.tier = handle_is_snap.sliderb.value
		inside[1] = n
	
	if urd: #update readout
		update_readout()

func set_fc():
	if Global.fusion_count >= Global.fusion_lim:
		Global.fusion_count = 0
		Global.move_shadows.emit()
	else:
		Global.fusion_count += 1
		Global.total_fusion_count += 1
		Global.alchemy.emit()
	
	var pr = remap(float(Global.fusion_count) / float(Global.fusion_lim),0,1,0.25,1) + 1.0
	cauldron_drop_zone.set_progress(pr)

func set_ta(n : aUnit):
	var ta : PackedInt32Array
	if Global.tiers_availible.has(n.get_nameb()):
		ta = Global.tiers_availible[n.get_nameb()]
	else: ta = [0]
	
	if ta.has(n.tier): return
	else:
		ta.append(n.tier)
		ta.sort()
		Global.tiers_availible[n.get_nameb()] = ta

func set_ppr():
	#Add Reaction to global
	var a := inside[0] if inside[0].get_particle_sum() < inside[1].get_particle_sum() else inside[1]
	var b := inside[1] if inside[1].get_particle_sum() > inside[0].get_particle_sum() else inside[0]
	var reaction = str(a.get_name(),"+",b.get_name())
	if Global.previously_performed_reactions.has(reaction): return
	Global.previously_performed_reactions.append(reaction)

func get_ordr() -> String:
	#Get ordered reaction
	var a := inside[0] if inside[0].get_particle_sum() < inside[1].get_particle_sum() else inside[1]
	var b := inside[1] if inside[1].get_particle_sum() > inside[0].get_particle_sum() else inside[0]
	return str(a.get_name(),"+",b.get_name())
