extends Object
class_name aUnit

enum types {
	auElement,
	auAlloy
}

var tier : int = 0

func get_name() -> String:
	return "Error"

func get_nameb() -> String:
	return "Error"

func get_nameg(_with_code := false) -> String:
	return "Error"

func get_namegb(_with_code := false) -> String:
	return "Error"

func same_tier_as(b : aUnit) -> bool:
	if b.tier == tier: return true
	return false

func get_particle_sum() -> int:
	return 0

func calculate_value(volatility := 0.0) -> float:
	return float((tier * 0.1) - volatility)

func set_random(_pmm : Vector2i, tmm : Vector2i = Vector2i.ZERO):
	tier = randi_range(tmm.x,tmm.y)

static func get_random(pmm : Vector2i = Vector2i(0,49), tmm : Vector2i = Vector2i.ZERO) -> aUnit:
	var new : aUnit = [Element,Alloy].pick_random().new()
	new.set_random(pmm,tmm)
	return new

static func clone(Unit : aUnit) -> aUnit:
	var clne : aUnit
	if Unit is Element:
		clne = Element.new()
		clne.particle = Unit.particle
		clne.tier = Unit.tier
		return clne
	if Unit is Alloy:
		clne = Alloy.new()
		clne.particleA = Unit.particleA
		clne.particleB = Unit.particleB
		clne.tier = Unit.tier
		return clne
	else:
		printerr("cloning failed")
		clne = aUnit.new()
		return clne
