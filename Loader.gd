extends ColorRect

@onready var progresstxt = $CenterContainer/HBoxContainer/progress
@onready var now_loading = $CenterContainer/HBoxContainer/now_loading
@onready var hang_notice = $CenterContainer/HBoxContainer/hang_notice

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ldr")
	fade(true)

func loadnew(new : String,show_per := false):
	if show_per: per()
	else: $CenterContainer.hide()
	await fade(false)
	#var c = get_tree().change_scene_to_file(new)
	get_tree().change_scene_to_packed(await load_p(new))
		#while true:
			#await get_tree().process_frame
			#if c in [OK,ERR_CANT_OPEN]: break
	await get_tree().create_timer(0.25).timeout
	fade(true)
	#else:
		#printerr("transition failed")

func load_p(new : String):
	var progress = []
	var oldp = -1
	var l = ResourceLoader
	if OS.has_feature("web"):
		l.load_threaded_request(new,"",true)
	else:
		l.load_threaded_request(new,"")
	while true:
		await get_tree().process_frame
		var status = l.load_threaded_get_status(new,progress)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			await get_tree().create_timer(0.2).timeout
			return ResourceLoader.load_threaded_get(new)
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			progresstxt.text = "err"
			now_loading.text = "resource failed to load"
			hang_notice.text = "sorry!"
			break
		elif oldp != progress[0]:
			progresstxt.text = str(round(progress[0]*100),"%")
			oldp = progress[0]

func per():
	progresstxt.text = "0%"
	now_loading.text = "now loading[wave]..."
	hang_notice.text = "it will hang, it shouldn't crash"
	$CenterContainer.show()

func fade(s : bool):
	var tw = create_tween()
	match s:
		true:
			tw.tween_property(self,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
			await tw.finished
			hide()
		false:
			show()
			tw.tween_property(self,"modulate:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
			await tw.finished
