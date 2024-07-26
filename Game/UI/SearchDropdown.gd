extends PanelContainer

var search_terms : PackedInt32Array = []
@onready var search = $VBoxContainer/Search
#@onready var option_button = $VBoxContainer/OptionButton

signal set_iso
var current

# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_exited.connect(update)
	pass # Replace with function body.

func setmeup(compound_name : String):
	if compound_name == current: return
	current = compound_name
	if Global.tiers_availible.has(compound_name):
		search_terms = Global.tiers_availible[compound_name]
	var x = str(search_terms[search_terms.size() - 1])
	select_option.text = x
	search.text = x

func test_A():
	var options : PackedInt32Array = []
	for i in randi_range(9,30):
		options.append(randi_range(0,999))
	search_terms = options
	print(search_terms)
	var input = "7"
	print("Closest match for '%s': %s" % [input, find_closest_match(input, options)])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_released() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var new = search_terms.find(int(select_option.text))
			var next = search_terms[(new + 1) % search_terms.size()]
			search.text = str(next)
			select_option.text = str(next)
			set_iso.emit(int(search.text))
		if event.is_released() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var new = search_terms.find(int(select_option.text))
			var next = search_terms[(new - 1) % (search_terms.size() - 1)]
			search.text = str(next)
			select_option.text = str(next)
			set_iso.emit(int(search.text))

func update():
	if search.text != "": 
		if !int(search.text) in search_terms: snap_valid(search.text)
		set_iso.emit(int(search.text))
		return
	elif select_option.text: 
		snap_valid(select_option.text)
		set_iso.emit(int(select_option.text))

func _on_search_text_changed(new_text):
	if !str(new_text).is_valid_int(): new_text = ""
	if new_text != "": do_search(new_text)
	else: closedrop()

func _on_search_text_submitted(new_text):
	if !str(new_text).is_valid_int(): new_text = ""
	if new_text != "": snap_valid(new_text)
	else: snap_valid(select_option.text)
	search.release_focus()
	closedrop()
	set_iso.emit(int(search.text))

#func _on_option_button_item_selected(index):
	#search.text = option_button.get_item_text(index)
	##option_button.release_focus()

@onready var select_option = $VBoxContainer/SelectOption
func _on_select_option_pressed():
	#opendrop()
	select_option.release_focus()
	if !dopen: do_search(search.text)
	elif dopen: closedrop()
	#elif search_terms.has(int(select_option.text)):
		#print("hi")
		#search.text = select_option.text

@onready var dd = $VBoxContainer/SelectOption/dd
@onready var ddvbc = $VBoxContainer/SelectOption/dd/ddpc/VBoxContainer
@onready var ddpc = $VBoxContainer/SelectOption/dd/ddpc
var dopen := false
func opendrop(options):
	dopen = true
	select_option.text = str(options[0])
	for i in ddvbc.get_children():
		i.get_parent().remove_child(i)
		i.queue_free()
	for i in options:
		var new = ddButton.new()
		new.text = str(i)
		new.selected.connect(selectdrop)
		ddvbc.add_child(new)
	ddpc.size.y = 0
	create_tween().tween_property(dd,"modulate:a",1,0.15).set_ease(Tween.EASE_IN_OUT)

func selectdrop(btn : ddButton):
	search.text = btn.text
	select_option.text = btn.text
	btn.release_focus()
	set_iso.emit(int(search.text))
	closedrop()

func closedrop():
	dopen = false
	for i in ddvbc.get_children():
		i.get_parent().remove_child(i)
		i.queue_free() 
	create_tween().tween_property(dd,"modulate:a",0,0.15).set_ease(Tween.EASE_IN_OUT)

func do_search(term):
	var t = search_terms.duplicate()
	var hits = []
	if search_terms.size() > 5:
		for i in 5:
			var cm = find_closest_match(str(term),t)
			hits.append(cm)
			if int(cm) in t:
				t.remove_at(t.find(int(cm)))
		
		var nclose = closest(int(term),search_terms)
		if !hits.has(str(nclose)): hits.append(str(nclose))
		for i in hits.count(""):
			hits.erase("")
		hits.sort_custom(sort_num)
		print(hits)
	else:
		for i in search_terms:
			hits.append(str(i))
	opendrop(hits)
	#set_opbtn(hits)

#func set_opbtn(opt : Array):
	#option_button.clear()
	#for i in opt:
		#option_button.add_item(str(i))
	#option_button.select(1)
	##option_button.show_popup()
	##option_button.release_focus()
	##search.grab_focus()

func snap_valid(value_changed):
	search.text = str(closest(int(value_changed),search_terms))
	#set_iso.emit(true)

func closest(value: int, vset: PackedInt32Array):
	var closest_value
	var closest_difference = INF
	
	for v in vset:
		var difference = abs(value - v)
		if difference < closest_difference:
			closest_difference = difference
			closest_value = v
	
	return closest_value

# Function to calculate the Levenshtein distance between two strings
func levenshtein_distance(s1: String, s2: String) -> int:
	var len_s1 = s1.length()
	var len_s2 = s2.length()
	
	# Initialize matrix
	var matrix = []
	for i in range(len_s1 + 1):
		matrix.append([])
		for j in range(len_s2 + 1):
			matrix[i].append(0)
	
	# Set up matrix
	for i in range(1, len_s1 + 1):
		matrix[i][0] = i
	for j in range(1, len_s2 + 1):
		matrix[0][j] = j
	
	# Compute Levenshtein distance
	for i in range(1, len_s1 + 1):
		for j in range(1, len_s2 + 1):
			var cost = 0 if s1[i - 1] == s2[j - 1] else 1
			matrix[i][j] = min(matrix[i - 1][j] + 1, # Deletion
			matrix[i][j - 1] + 1, # Insertion
			matrix[i - 1][j - 1] + cost) # Substitution
	
	return matrix[len_s1][len_s2]

# Function to calculate similarity based on Levenshtein distance
func similarity(s1: String, s2: String) -> float:
	var max_len = max(s1.length(), s2.length())
	if max_len == 0:
		return 1.0  # Both strings are empty
	return 1.0 - float(levenshtein_distance(s1, s2)) / float(max_len)

# Function to find the closest match from a list of options
func find_closest_match(input: String, options: Array) -> String:
	var best_match = ""
	var highest_similarity = 0.0
	for option in options:
		var sim = similarity(input, str(option))
		if sim > highest_similarity:
			highest_similarity = sim
			best_match = option
	return str(best_match)

func sort_num(a : String,b : String) -> bool:
	if int(a) < int(b): return true
	return false
