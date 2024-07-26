extends aUnit
class_name Element

enum PERIODIC_TABLE {
	A,
	B,
	C,
	D,
	E,
	F,
	G,
	H,
	I,
	J,
	K,
	L,
	M,
	N,
	O,
	P,
	Q,
	R,
	S,
	T,
	U,
	V,
	W,
	X,
	Y,
	Z,
	ALPHA,
	BETA,
	GAMMA,
	DELTA,
	EPSILON,
	ZETA,
	ETA,
	THETA,
	IOTA,
	KAPPA,
	LAMBDA,
	MU,
	NU,
	XI,
	OMICRON,
	PY,
	RHO,
	SIGMA,
	YAU,
	UPSILON,
	PHI,
	CHI,
	PSI,
	OMEGA,
}

var particle : PERIODIC_TABLE

func same_element(b : Element) -> bool:
	if particle == b.particle: return true
	return false

func exact_same_element(b : Element) -> bool:
	if same_element(b) and same_tier_as(b): return true
	return false

func get_name() -> String:
	var n = Element.PERIODIC_TABLE.keys()[particle]
	var name : String = str(n,"*",tier).to_lower()
	#a*0
	return name

func get_nameb() -> String:
	var n = Element.PERIODIC_TABLE.keys()[particle]
	var name : String = str(n,"*").to_lower()
	#a*
	return name

func get_nameg(with_code := false) -> String:
	var n = Element.PERIODIC_TABLE.keys()[particle]
	var name : String = str(n).to_lower()
	if particle > 25: name = Element.greek_string(name,with_code)
	#a
	return name

func get_namegb(with_code := false) -> String:
	var n = Element.PERIODIC_TABLE.keys()[particle]
	var name : String 
	if tier != 0:
		name = str(n,"*",tier).to_lower()
	else: name = str(n).to_lower()
	if particle > 25: name = Element.greek_string(name,with_code)
	#a*0
	return name

func get_particle_sum() -> int:
	return particle

func calculate_value(volatility := 0.0) -> float:
	var v = (particle + 1) + (tier * 0.1) - volatility
	return v

func set_random(pmm : Vector2i = Vector2i(0,49), tmm : Vector2i = Vector2i.ZERO):
	var r : int = clamp(randi_range(pmm.x,pmm.y),0,49)
	particle = PERIODIC_TABLE[PERIODIC_TABLE.keys()[r]]
	tier = clamp(randi_range(tmm.x,tmm.y),0,101)

static func get_random(pmm : Vector2i = Vector2i(0,49), tmm : Vector2i = Vector2i.ZERO) -> Element:
	var new : Element = Element.new()
	new.set_random(pmm,tmm)
	return new

#e62200 RED
#ffd500 YELLOW
#2e8ae6 BLUE
#ff3399 PINK
#fff9f2 IVORY
const pRED = Color("#e62200") #Akuma Acids
const pYELLOW = Color("#ffd500") #Solfire Sugars 
const pBLUE = Color("#2e8ae6") #Heavenblue Beozars
const pPINK = Color("#ff3399") #Ganfuschias
const pIVORY = Color("#fff9f2") #Angelwing Salts
static func get_particle_color(p : int,darken := true) -> Color:
	var c : Color
	if p in range(0,10):
		c = pRED
	elif p in range(10,20):
		c = pYELLOW
	elif p in range(20,30):
		c = pBLUE
	elif p in range(30,40):
		c = pPINK
	elif p in range(40,50):
		c = pIVORY
	else:
		c = Color.BLACK
		printerr("NOT IN RANGE")
	
	if darken:
		var darkmod = remap((float(p%10)/10.0),0.0,1.0,0.0,0.8)
		c = c.darkened(darkmod)
	#print_rich("[color=",c.to_html(),"] I'm this COLOR #### ",darkmod)
	return c

static func get_particle_icon(p : int) -> Rect2:
	var columns : int = 10
	var row = p / columns
	var column = p % columns
	var region := Rect2(column * 96,row * 96,96,96)
	return region

static func greek_string(s : String, with_code := false) -> String:
	var wc = "[code]" if with_code else ""
	var wce = "[/code]" if with_code else ""
	s = s.replace("alpha", str(wc,"α",wce))
	s = s.replace("beta", str(wc,"β",wce))
	s = s.replace("gamma", str(wc,"γ",wce))
	s = s.replace("delta", str(wc,"δ",wce))
	s = s.replace("epsilon", str(wc,"ε",wce))
	s = s.replace("zeta", str(wc,"ζ",wce))
	s = s.replace("theta", str(wc,"θ",wce))
	s = s.replace("eta", str(wc,"η",wce))
	s = s.replace("iota", str(wc,"ι",wce))
	s = s.replace("kappa", str(wc,"κ",wce))
	s = s.replace("lambda", str(wc,"λ",wce))
	s = s.replace("mu", str(wc,"μ",wce))
	s = s.replace("nu", str(wc,"ν",wce))
	s = s.replace("xi", str(wc,"ξ",wce))
	s = s.replace("omicron", str(wc,"ο",wce))
	s = s.replace("py", str(wc,"π",wce))
	s = s.replace("rho", str(wc,"ρ",wce))
	s = s.replace("sigma", str(wc,"σ",wce))
	s = s.replace("yau", str(wc,"τ",wce))
	s = s.replace("upsilon", str(wc,"υ",wce))
	s = s.replace("phi", str(wc,"φ",wce))
	s = s.replace("chi", str(wc,"χ",wce))
	s = s.replace("psi", str(wc,"ψ",wce))
	s = s.replace("omega", str(wc,"ω",wce))
	return s
