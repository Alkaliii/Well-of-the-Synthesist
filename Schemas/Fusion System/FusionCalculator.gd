extends Object
class_name Alchemy

const table_size := 49
enum rx {
	NULL,
	POLYMER_REACTION,
	ALLOY_SYNTHESIS,
	TRANSFORMATION_SYNTHESIS,
	POLYMER_REVOLUTION,
	ALLOY_POLYMER_REVOLUTION,
	TRANSMUTATION,
	DECAY,
	ALLOY_DECAY,
	HYPER_DECAY,
	HYPER_ALLOY_DECAY,
	CHEMISTRY, #for producing mixtures
}
var reaction_performed : rx = rx.NULL

func can_pr(a : aUnit, b : aUnit) -> bool:
	var pr = perform_reaction(a,b)
	if pr is aUnit or pr is Mixture: return true
	return false

func can_dk(a : aUnit,hyper := false) -> bool:
	if perform_decay(a,hyper) is aUnit: return true
	return false

func perform_reaction(a : aUnit, b : aUnit):
	var a_type = aUnit.types.auElement if a is Element else aUnit.types.auAlloy
	var b_type = aUnit.types.auElement if b is Element else aUnit.types.auAlloy
	
	if a_type != b_type: 
		#Chemistry
		if a_type == aUnit.types.auElement:
			return chemical_reaction(a,b)
		else: return chemical_reaction(b,a)
	 
	if a_type == aUnit.types.auElement: return elemental_reaction(a,b)
	if a_type == aUnit.types.auAlloy: return alloy_reaction(a,b)
	
	#Something went wrong
	return true

func perform_decay(a : aUnit,hyper := false):
	if a is Element:
		#Normal Decay
		if a.particle == Element.PERIODIC_TABLE.A: 
			#You cannot decay below A
			return false
		var new := Element.new()
		new.particle = new_particle(a.particle,-1)
		new.tier = 0
		reaction_performed = rx.DECAY if !hyper else rx.HYPER_DECAY
		return new
	elif hyper and a is Alloy:
		#Hyper Decay Alloy
		var new := Element.new()
		new.particle = [a.particleA,a.particleB].pick_random()
		new.tier = 0
		reaction_performed = rx.HYPER_ALLOY_DECAY
		return new
	elif a is Alloy:
		#Normal Decay Alloy
		var new := Alloy.new()
		new.particleA = new_particle(a.particleA,-1)
		new.particleB = new_particle(a.particleB,-1)
		new.tier = 0
		reaction_performed = rx.ALLOY_DECAY
		return new
	else:
		#Something went wrong
		return true

func chemical_reaction(a: Element, b: Alloy):
	var m = Mixture.new()
	m.m1 = a
	m.m2 = b
	m.created_in_shadow = Global.in_shadow
	m.impurities = Global.total_fusion_count
	m.static_volatility = Global.volatility
	reaction_performed = rx.CHEMISTRY
	return m

func alloy_reaction(a: Alloy, b: Alloy):
	if a.exact_same_alloy(b):
		#Polymer Reaction : Adding two of the same thing together increases tier by 1
		var new := Alloy.new()
		new.particleA = a.particleA
		new.particleB = b.particleB
		new.tier = clamp(a.tier + 1,0,101)
		#Emit signal to notify Polymer Reaction Occured
		reaction_performed = rx.POLYMER_REACTION
		print("Polymer Reaction Occured, ",a.get_name(),"+",b.get_name(),"=",new.get_name())
		return new
	elif a.same_alloy(b):
		#Alloy Polymer Revolution: Adding to of the same alloy with different tiers produces a new alloy using sum of tiers
		var new := Alloy.new()
		var sum := a.tier + b.tier
		new.particleA = new_particle(a.particleA,sum)#(a.particleA + sum) % table_size
		new.particleB = new_particle(b.particleB,sum)#(b.particleB + sum) % table_size
		new.tier = 0
		#Emit signal to notify Alloy Polymer Revolution Occured
		reaction_performed = rx.ALLOY_POLYMER_REVOLUTION
		print("Polymer Revolution Occured, ",a.get_name(),"+",b.get_name(),"=",new.get_name())
		return new
	elif a.same_tier_as(b):
		#Transformation Synthesis : Element particle is largest in reaction + 1, tier is sum of differences other way around
		var new := Element.new()
		var mpo = new_particle([a.particleA,a.particleB,b.particleA,b.particleB].max(),1)
		var diff = clamp(abs(a.particleA - a.particleB) + abs(b.particleA - b.particleB),0,101)
		new.particle = diff % (table_size + 1)
		new.tier = mpo
		#Emit signal to notify Transformation Synthesis Occured
		reaction_performed = rx.TRANSFORMATION_SYNTHESIS
		print("Transformation Synthesis Occured, ",a.get_name(),"+",b.get_name(),"=",new.get_name())
		return new
	else:
		#Transmuation : Element particle is largest in reaction + 1, tier is sum of differences plus sum of tiers other way around
		var new := Element.new()
		var sum := a.tier + b.tier
		var mpo = new_particle([a.particleA,a.particleB,b.particleA,b.particleB].max(),1)
		var diff = clamp(abs(a.particleA - a.particleB) + abs(b.particleA - b.particleB) + sum,0,101)
		new.particle = diff % (table_size + 1)
		new.tier = mpo
		#Emit signal to notify Transmuation Occured
		reaction_performed = rx.TRANSMUTATION
		print("Transmutation Occured, ",a.get_name(),"+",b.get_name(),"=",new.get_name())
		return new

func elemental_reaction(a : Element, b : Element):
	if a.exact_same_element(b):
		#Polymer Reaction : Adding two of the same thing together increases tier by 1
		var new := Element.new()
		new.particle = a.particle
		new.tier = a.tier + 1
		#Emit signal to notify Polymer Reaction Occured
		reaction_performed = rx.POLYMER_REACTION
		print("Polymer Reaction Occured, ",a.get_name(),"+",b.get_name(),"=",new.get_name())
		return new
	elif a.same_element(b):
		#Polymer Revolution : Adding two of the same particles with different tiers produces a new particle using sum of tiers
		var new := Element.new()
		var sum := a.tier + b.tier
		new.particle = new_particle(a.particle,sum)#(a.particle + sum) % table_size
		new.tier = 0
		#Emit signal to notify Polymer Revolution Occured
		reaction_performed = rx.POLYMER_REVOLUTION
		print("Polymer Revolution Occured, ",a.get_name(),"+",b.get_name(),"=",new.get_name())
		return new
	else: #Alloy Synthesis
		#Alloy Synthesis : Adding two elements of produces an Alloy with a sum of tiers
		var new := Alloy.new()
		new.particleA = [a.particle,b.particle].min()
		new.particleB = [a.particle,b.particle].max()
		new.tier = clamp(a.tier + b.tier,0,101)
		#Emit signal to notify Alloy Synthesis Occured
		reaction_performed = rx.ALLOY_SYNTHESIS
		print("Alloy Synthesis Occured, ",a.get_name(),"+",b.get_name(),"=",new.get_name())
		return new

func new_particle(base : int, mod : int) -> int:
	var new = clamp(base + mod,0,table_size)
	return new
