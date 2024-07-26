extends Object
class_name Mixture
#Alchemic Endproduct (you submit this to the leaderboard)

var m1 : Element
var m2 : Alloy
var created_in_shadow : bool
var impurities : int
var static_volatility

# (Element Value * Alloy Value) * Synergy (pick noise from 3D space) - Volatility
# alignment = element particle value + alloy a particle value + alloy b particle value 
#if alignment is odd you produced a shadow mixture if it was not performed in shadow half value
#if alignment is even you produced a luminescence mixture if it was performed in shadow half value

func get_name() -> String:
	var s = str(m1.get_nameb(),m2.get_nameb(),["-","+"][get_alignment()])
	for i in s.count("*"):
		s = s.replace("*","")
	#a+
	return s

func get_nameb() -> String:
	var s = get_name()
	return s

func get_nameg(with_code := false) -> String:
	var s = str(m1.get_nameg(with_code),m2.get_nameg(with_code),["-","+"][get_alignment()])
	for i in s.count("*"):
		s = s.replace("*","")
	#a+
	return s

func get_namegb(with_code := false) -> String:
	var s = get_nameg(with_code)
	return s

func get_alignment() -> int:
	#0 dark
	#1 light
	var a = m1.particle + m2.particleA + m2.particleB
	if a % 2 == 1: #Odd
		return 0
	if a % 2 == 0: #Even
		return 1
	return -1

func is_aligned() -> bool:
	if get_alignment() == 0 and created_in_shadow: return true
	elif get_alignment() == 1 and !created_in_shadow: return true
	return false

func hypersaturated() -> bool:
	var elements = [m1.particle,m2.particleA,m2.particleB]
	for e in elements:
		if elements.count(e) > 1: return true
	return false

func oversaturated() -> bool:
	var elements = [m1.particle,m2.particleA,m2.particleB]
	var colors = []
	for e in elements:
		colors.append(Element.get_particle_color(e,false))
	
	for c in colors:
		if colors.count(c) > 1: return true
	return false

func get_synergy(isosum : int) -> float:
	var MS = await Global.get_ms(51,51,51,isosum)
	var syn = MS[m2.particleB].get_pixel(m1.particle,m2.particleA).r
	return syn

func calculate_value() -> float:
	var isosum = m1.tier + m2.tier
	var syn = await get_synergy(isosum)
	var m1v = m1.calculate_value(static_volatility)
	var m2v = m2.calculate_value(static_volatility)
	var v = ((m1v * m2v) * remap(syn,0,1,0.1,2)) - static_volatility
	
	var a = m1.particle + m2.particleA + m2.particleB
	if a % 2 == 1 and !created_in_shadow: #Odd
		v /= 2.0
	if a % 2 == 0 and created_in_shadow: #Even
		v /= 2.0
	
	if hypersaturated():
		v = v * 0.8
	if oversaturated():
		v = v * 0.85
	
	v -= impurities / 2
	
	return v

func set_random(pmm : Vector2i = Vector2i(0,49), tmm : Vector2i = Vector2i.ZERO):
	m1 = Element.get_random(pmm,tmm)
	m2 = Alloy.get_random(pmm,tmm)
	created_in_shadow = [true,false].pick_random()
	impurities = randi_range(0,1000)

static func get_random(pmm : Vector2i = Vector2i(0,49), tmm : Vector2i = Vector2i.ZERO) -> Mixture:
	var new : Mixture = Mixture.new()
	new.set_random(pmm,tmm)
	return new
