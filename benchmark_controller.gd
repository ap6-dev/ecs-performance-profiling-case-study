extends Node
#Terminal Command
# godot4 --headless

#===============================================================================
# Benchmark test variables
#===============================================================================
enum UpdateMode {PER_NPC_PROCESS, BATCHED_CONTROLLER, ECS_SOA_SINGLE, ECS_SOA_THREADS}
var tiers = [
	UpdateMode.PER_NPC_PROCESS,
	UpdateMode.BATCHED_CONTROLLER,
	UpdateMode.ECS_SOA_SINGLE,
	UpdateMode.ECS_SOA_THREADS
]
var test_counts := [100, 1_000, 10_000, 100_000]

#===============================================================================
# Other Testing Variables
#===============================================================================
var cur_test := 0
var npc_count := 0
var frame_count := 0

var time_accum_msec := 0.0

var warmup_frames := 120
var measure_frames := 300

var measuring := false

var update_mode : UpdateMode

var npcs := []
var pos_x : PackedFloat32Array
var pos_y : PackedFloat32Array
var pos_z : PackedFloat32Array
var vel_x : PackedFloat32Array
var vel_y : PackedFloat32Array
var vel_z : PackedFloat32Array

#===============================================================================
# Initialize seed and setup tests
#===============================================================================
func _ready() -> void:
	
	randomize()
	resize_arrays(1_000_000)
	init_benchmark_tests()

#===============================================================================
# Iterate through each test tier at each npc count. (Skip super slow ones)
#===============================================================================
func init_benchmark_tests():
	for tier in tiers:
		update_mode = tier
		for count in test_counts:
			npc_count = count
			
			if update_mode == UpdateMode.PER_NPC_PROCESS and count > 100_000:
				print("Skipping ", count, " NPCs for Per-node mode (too slow).")
				continue
			
			run_benchmark_for_current_settings()
	
#===============================================================================
# 
#===============================================================================
func run_benchmark_for_current_settings():
	spawn_npcs_or_arrays()
	
	var last_time
	
	
	while frame_count < warmup_frames + measure_frames:
		if frame_count >=  warmup_frames:
			var frame_sec : float
			# Start Measuring
			if update_mode == UpdateMode.PER_NPC_PROCESS:
				measuring = true
			else: 
				frame_sec = measure_batched_loop()
		
		frame_count += 1
	var avg_frame_msec = time_accum_msec / measure_frames
	print("Avg Frame time: ", avg_frame_msec, " ms")
	
	if update_mode == UpdateMode.PER_NPC_PROCESS: cleanup_npcs()

#===============================================================================
# 
#===============================================================================
func spawn_npcs_or_arrays():
	if update_mode == UpdateMode.PER_NPC_PROCESS or update_mode == UpdateMode.BATCHED_CONTROLLER:
		var npc_scene := preload("res://npc_node.tscn")
		for i in npc_count:
			var npc = npc_scene.instantiate()
			npc.visible = false #No rendering
			#if update_mode == UpdateMode.BATCHED_CONTROLLER:
				#npc.set_process(false)
			add_child(npc)
			npcs.append(npc)
	else:
		for i in npc_count:
			pos_x[i] = 0.0
			pos_y[i] = 0.0
			pos_z[i] = 0.0
			vel_x[i] = randf_range(-1.0, 1.0)
			vel_y[i] = 0.0
			vel_z[i] = randf_range(-1.0, 1.0)

#===============================================================================
# 
#===============================================================================
func measure_batched_loop() -> float:
	#if update_mode == UpdateMode.BATCHED_CONTROLLER:
		#var accum
		#var start = Time.get_ticks_msec()
		#for npc in npcs:
			#npc.position += npc.velocity * custom_delta
		#var end = Time.get_ticks_msec()
		#accum += (start - end)
		#print("Avg Frame time: ", accum / (warmup_frames + measure_frames), " ms")
		return 0
#===============================================================================
# 
#===============================================================================
#func run_next_test():
	#if cur_test >= test_counts.size():
		#print("\nAll benchmarks completed in: ", Time.get_ticks_msec() / 1000, " seconds")
		#get_tree().quit()
		#return
	#npc_count = test_counts[cur_test]
	#print("\nStarting Benchmark for ", npc_count, " NPCs")
	#
	##spawn_npcs()
	#
	#frame_count = 0
	#time_accum_usec = 0
	#measuring = true
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not measuring:
		return

	if frame_count >= warmup_frames:
		var frame_sec = Performance.get_monitor(Performance.TIME_PROCESS)
		time_accum_msec += frame_sec * 1000

	frame_count += 1

	if frame_count >= warmup_frames + measure_frames:
		var avg_msec = time_accum_msec / measure_frames
		print("NPCs: ", npc_count)
		print("Avg frame time: ", "%.6f" % (avg_msec), " ms")
		measuring = false

func cleanup_npcs():
	for npc in npcs:
		npc.queue_free()
	npcs.clear()

#===============================================================================
# 
#===============================================================================
func resize_arrays(size: int):
	pos_x.resize(size)
	pos_y.resize(size)
	pos_z.resize(size)
	vel_x.resize(size)
	vel_y.resize(size)
	vel_z.resize(size)
