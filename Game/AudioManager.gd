extends Node
class_name AudioManager

var num_players := 8

var available : Array[AudioStreamPlayer] = []
var queue_sound = []
var queue_bus = []
var queue_pitch = []
var queue_volume = []

var looping : Array[AudioStreamPlayer] = []
var loop_paths : Array = []

func _ready():
	AudioServer.set_bus_volume_db(1,linear_to_db(0.5))
	#AudioServer.set_bus_volume_db(1,linear_to_db(0.8))
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.finished.connect(_stream_finished.bind(p))

func _stream_finished(stream):
	available.append(stream)

func loop(sound_path,bus = "master", pitch : float = 1.0):
	var lasp := AudioStreamPlayer.new()
	add_child(lasp)
	looping.append(lasp)
	loop_paths.append(sound_path)
	lasp.stream = load(sound_path)
	lasp.bus = bus
	lasp.pitch_scale = pitch
	lasp.play()

func stop_loop(sound_path,fade_length := 0.25):
	for l in loop_paths:
		if l == sound_path:
			var tw = create_tween()
			var asp = looping[loop_paths.find(l)]
			tw.tween_property(asp,"volume_db",linear_to_db(0.0),fade_length).set_ease(Tween.EASE_IN_OUT)
			await tw.finished
			loop_paths.erase(l)
			looping.erase(asp)
			remove_child(asp)
			asp.queue_free()
			break

func pause_loop(sound_path, pause := false):
	for l in loop_paths:
		if l == sound_path:
			var asp = looping[loop_paths.find(l)]
			asp.stream_paused = pause

func play(sound_path,bus = "master",pitch : float = 1.0,volume : float = 1.0):
	queue_sound.append(sound_path)
	queue_bus.append(bus)
	queue_pitch.append(pitch)
	queue_volume.append(volume)

func clean_players():
	if available.size() > num_players:
		var kill = available.pop_back()
		remove_child(kill)
		kill.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#play sound
	if !queue_sound.is_empty() and !available.is_empty():
		available[0].stream = load(queue_sound.pop_front())
		available[0].bus = queue_bus.pop_front()
		available[0].pitch_scale = queue_pitch.pop_front()
		available[0].volume_db = linear_to_db(queue_volume.pop_front())
		available[0].play()
		available.pop_front()
	#play sound on a temp new
	elif !queue_sound.is_empty() and available.is_empty():
		var np = AudioStreamPlayer.new()
		add_child(np)
		np.finished.connect(_stream_finished.bind(np))
		np.stream = load(queue_sound.pop_front())
		np.bus = queue_bus.pop_front()
		np.pitch_scale = queue_pitch.pop_front()
		np.volume_db = linear_to_db(queue_volume.pop_front())
		np.play()
	elif queue_sound.is_empty() and !available.is_empty():
		clean_players()
