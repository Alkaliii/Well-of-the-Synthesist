extends PanelContainer

@export var debug := false
const BIG_PLACEMENT = preload("res://Game/UI/big_placement.tscn")
const SMALL_PLACEMENT = preload("res://Game/UI/small_placement.tscn")

@onready var lblist = $ScrollContainer/lblist
var leaderboard

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	if debug: disp_lb()

func disp_lb():
	#clear
	for r in lblist.get_children():
		r.get_parent().remove_child(r)
		r.queue_free()
	
	Firebase.Auth.login_anonymous()
	await Firebase.Auth.signup_succeeded
	leaderboard = await Firebase.Firestore.list('wots_best_elixir')
	leaderboard.sort_custom(order_fb)
	await get_tree().process_frame
	print(leaderboard)
	
	var idx := 0
	for s in leaderboard:
		if !s is FirestoreDocument: continue
		if idx > 15:
			var del_task: FirestoreCollection = Firebase.Firestore.collection('wots_best_elixir')
			var document = await del_task.delete(s)
			continue
		
		var new = BIG_PLACEMENT.instantiate() if idx <= 2 else SMALL_PLACEMENT.instantiate()
		lblist.add_child(new)
		new.set_details(idx,s.document)
		idx += 1

func submit_score(d := {}):
	if !Firebase.Auth.is_logged_in():
		Firebase.Auth.login_anonymous()
		await Firebase.Auth.signup_succeeded
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection('wots_best_elixir')
	
	#var doc := FirestoreDocument.new()
	#doc.doc_name = d["player_name"]
	#doc.add_or_update_field("mixture",d["mixture"])
	#doc.add_or_update_field("player_name",d["player_name"])
	#doc.add_or_update_field("score",d["score"])
	#doc.add_or_update_field("sum",d["sum"])
	
	var update := false
	var udoc : FirestoreDocument = null
	if leaderboard:
		for s in leaderboard:
			if s.document["player_name"].values()[0] == d["player_name"] and s.document["score"].values()[0] < d["score"]:
				update = true
				udoc = s
				udoc.add_or_update_field("score",d["score"])
				break
	
	if update and udoc:
		await firestore_collection.update(udoc)
	else:
		if Global.consumed_mixture:
			d["raw"] = await Global.consumed_mixture.calculate_value()
			d["cis"] = Global.consumed_mixture.created_in_shadow
			d["impurities"] = Global.consumed_mixture.impurities
			d["voli"] = Global.consumed_mixture.static_volatility
			d["oversat"] = Global.consumed_mixture.oversaturated()
			d["hypersat"] = Global.consumed_mixture.hypersaturated()
			d["boost_latin"] = Global.boost_latin
			d["boost_greek"] = Global.boost_greek
			d["used_cheats"] = Global.used_cheats
			d["final_move_count"] = Global.move_count
		await firestore_collection.add(str(d["player_name"],"-",ugen.v4()),d)
	
	disp_lb()

static func order_fb(a : FirestoreDocument, b : FirestoreDocument):
	if float(a.document["score"].values()[0]) > float(b.document["score"].values()[0]): 
		return true
	elif (float(a.document["score"].values()[0]) == float(b.document["score"].values()[0])) and (a.document["player_name"].values()[0] > b.document["player_name"].values()[0]): 
		return true
	return false
