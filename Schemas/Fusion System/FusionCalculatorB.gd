extends Node
class_name AlchemyB

const table_size := 49
enum rx {
	NULL,
	MERGE_SYNTHESIS, #(a+a=b)(ab+ab=bc) two of the same thing become the same but bigger
	ALLOY_SYNTHESIS, #(a+b=ab)
	RECOMBINATION_SYNTHESIS, #(ab+cd=ac,bd)
	CHEMISTRY, #(a+bc=abc)
	DECAY, #can only be performed out of shadow (z = y)
	ALLOY_DECAY, #can only be performed out of shadow (yz = y,z)
}
var reaction_performed : rx = rx.NULL

func can_dk(a : aUnit) -> bool:
	if decay_rx(a).is_empty(): return false
	return true

func decay_rx(a : aUnit) -> Array[Element]:
	if a is Element:
		reaction_performed = rx.DECAY
		var new = Element.new()
		new.particle = new_particle(a.particle,-1)
		new.tier = 0
		return [new]
	elif a is Alloy:
		reaction_performed = rx.ALLOY_DECAY
		var newA = Element.new()
		newA.particle = a.particleA
		newA.tier = 0
		var newB = Element.new()
		newB.particle = a.particleB
		newB.tier = 0
		return [newA,newB]
	return []

func can_pr(a : aUnit, b : aUnit) -> bool:
	if perform_rx(a,b).is_empty(): return false
	return true

func perform_rx(a : aUnit, b : aUnit) -> Array:
	if a is Element and b is Element:
		return elemental_rx(a,b)
	elif a is Alloy and b is Alloy:
		return alloy_rx(a,b)
	elif a is Element and b is Alloy:
		return chemical_rx(a,b)
	elif a is Alloy and b is Element:
		return chemical_rx(b,a)
	return []

func chemical_rx(a : Element, b : Alloy) -> Array[Mixture]:
	var phb = Global.get_tree().get_first_node_in_group("phb")
	if phb.in_hotbar.size() == 4: 
		SFXm.play("res://Assets/Sounds/error_006.ogg","master",randf_range(0.9,1.1))
		var n = str("You can only hold [color=white]4[/color] mixtures at once. Please dispose.")
		Global.smallnote.emit(n)
		return []
	reaction_performed = rx.CHEMISTRY
	var new = Mixture.new()
	new.m1 = a
	new.m2 = b
	new.created_in_shadow = Global.in_shadow
	new.impurities = Global.total_fusion_count
	new.static_volatility = Global.volatility
	return [new]

func alloy_rx(a : Alloy, b : Alloy) -> Array[Alloy]:
	if a.particleA == b.particleA and a.particleB == b.particleB:
		#merge synthesis
		reaction_performed = rx.MERGE_SYNTHESIS
		var new = Alloy.new()
		new.particleA = new_particle(a.particleA,1)
		new.particleB = new_particle(b.particleB,1)
		new.tier = 0
		return [new]
	else:
		#recombination synthesis
		reaction_performed = rx.RECOMBINATION_SYNTHESIS
		var newA = Alloy.new()
		newA.particleA = [a.particleA,b.particleA].min()
		newA.particleB = [a.particleA,b.particleA].max()
		newA.tier = 0
		var newB = Alloy.new()
		newB.particleA = [a.particleB,b.particleB].min()
		newB.particleB = [a.particleB,b.particleB].max()
		newB.tier = 0
		return [newA,newB]

func elemental_rx(a : Element, b: Element) -> Array[aUnit]:
	if a.particle == b.particle:
		#merge synthesis
		reaction_performed = rx.MERGE_SYNTHESIS
		var new = Element.new()
		new.particle = new_particle(a.particle,1)
		new.tier = 0
		return [new]
	else:
		#alloy synthesis
		reaction_performed = rx.ALLOY_SYNTHESIS
		var new = Alloy.new()
		new.particleA = [a.particle,b.particle].min()
		new.particleB = [a.particle,b.particle].max()
		new.tier = 0
		return [new]

func new_particle(base : int, mod : int) -> int:
	var new = clamp(base + mod,0,table_size)
	return new
