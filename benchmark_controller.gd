extends Node
#Terminal Command
# godot4 --headless
var test_counts := [100, 1_000, 10_000, 100_000]
var npc_count := 0
var cur_test := 0

var time_accum_usec := 0.0
var frame_count := 0
var warmup_frames := 120
var measure_frames := 300
var last_frame_time := 0
var measuring := false

var npcs := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parse_cli_args()
	randomize()
	run_next_test()

func spawn_npcs():
	var npc_scene := preload("res://npc_node.tscn")
	for i in npc_count:
		var npc = npc_scene.instantiate()
		npc.visible = false #No rendering
		add_child(npc)
		npcs.append(npc)
	#print("Spawned ", npc_count, " NPCs")

func run_next_test():
	if cur_test >= test_counts.size():
		print("\nAll benchmarks completed in: ", Time.get_ticks_msec() / 1000, " seconds")
		get_tree().quit()
		return
	npc_count = test_counts[cur_test]
	print("\nStarting Benchmark for ", npc_count, " NPCs")
	
	spawn_npcs()
	
	frame_count = 0
	time_accum_usec = 0
	measuring = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not measuring:
		return
		
	if frame_count < warmup_frames:
		frame_count += 1
		return
	
	var start := Time.get_ticks_usec()

	for npc in npcs:
		npc.position += npc.velocity * delta

	var end := Time.get_ticks_usec()
	
	time_accum_usec += (end - start)
	frame_count += 1

	if frame_count == warmup_frames + measure_frames:
		var avg_usec := time_accum_usec / measure_frames
		var avg_ms := avg_usec / 1000.0

		print("NPCs: ", npc_count, " | Avg simulation time (ms): ", avg_ms)

		cleanup_npcs()
		cur_test += 1
		run_next_test()

func cleanup_npcs():
	for npc in npcs:
		npc.queue_free()
	npcs.clear()

func parse_cli_args():
	var args = OS.get_cmdline_user_args()

	for arg in args:
		if arg.begins_with("--npc_count="):
			npc_count = int(arg.get_slice("=", 1))
