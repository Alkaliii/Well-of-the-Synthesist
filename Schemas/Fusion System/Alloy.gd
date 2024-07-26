extends aUnit
class_name Alloy

var particleA : Element.PERIODIC_TABLE
var particleB : Element.PERIODIC_TABLE
#A should always be the smaller element

func same_alloy(b : Alloy) -> bool:
	if [particleA,particleB] == [b.particleA,b.particleB]: return true
	return false

func exact_same_alloy(b : Alloy) -> bool:
	if same_alloy(b) and same_tier_as(b): return true
	return false

func get_name() -> String:
	var n1 = Element.PERIODIC_TABLE.keys()[particleA]
	var n2 = Element.PERIODIC_TABLE.keys()[particleB]
	var name : String = str(n1,n2,"*",tier).to_lower()
	#ab*0
	return name

func get_nameb() -> String:
	var n1 = Element.PERIODIC_TABLE.keys()[particleA]
	var n2 = Element.PERIODIC_TABLE.keys()[particleB]
	var name : String = str(n1,n2,"*").to_lower()
	#ab*
	return name

func get_nameg(with_code := false) -> String:
	var n1 = Element.PERIODIC_TABLE.keys()[particleA]
	var n2 = Element.PERIODIC_TABLE.keys()[particleB]
	var name : String = str(n1,"/*",n2).to_lower()
	if particleA > 25 or particleB > 25:
		name = Element.greek_string(name,with_code)
		pass
	name = name.replacen("/*","")
	#ab
	return name

func get_namegb(with_code := false) -> String:
	var n1 = Element.PERIODIC_TABLE.keys()[particleA]
	var n2 = Element.PERIODIC_TABLE.keys()[particleB]
	var name : String 
	if tier != 0:
		name = str(n1,"/*",n2,"*",tier).to_lower()
	else: name = str(n1,"/*",n2).to_lower()
	if particleA > 25 or particleB > 25:
		name = Element.greek_string(name,with_code)
		pass
	name = name.replacen("/*","")
	#ab*0
	return name

func get_particle_sum() -> int:
	return particleA + particleB

func calculate_value(volatility := 0.0) -> float:
	var syn = Global.AS.get_image().get_pixel(particleA,particleB).r
	var v = ((((particleA+1) * (particleB+1)) + (tier * 0.1)) * remap(syn,0,1,0.1,2)) - volatility
	return v

func set_random(pmm : Vector2i = Vector2i(0,49), tmm : Vector2i = Vector2i.ZERO):
	var r1 : int = clamp(randi_range(pmm.x,pmm.y),0,49)
	var r2 : int = clamp(randi_range(pmm.x,pmm.y),0,49)
	var p1 : Element.PERIODIC_TABLE = Element.PERIODIC_TABLE[Element.PERIODIC_TABLE.keys()[r1]]
	var p2 : Element.PERIODIC_TABLE = Element.PERIODIC_TABLE[Element.PERIODIC_TABLE.keys()[r2]]
	particleA = [p1,p2].min()
	particleB = [p1,p2].max()
	tier = clamp(randi_range(tmm.x,tmm.y),0,101)

static func get_random(pmm : Vector2i = Vector2i(0,49), tmm : Vector2i = Vector2i.ZERO) -> Alloy:
	var new : Alloy = Alloy.new()
	new.set_random(pmm,tmm)
	return new

static func get_alloy_color(pA : int, pB : int) -> Color:
	var col : Color = Element.get_particle_color(pA)
	col = col.lerp(Element.get_particle_color(pB),0.5)
	return col
