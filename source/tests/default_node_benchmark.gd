extends Node

@export var npc_scene : PackedScene #NPC node scene reference
var npcs := [] #Array of instantiated NPC nodes

var test_counter := 0 #Counter for no of tests ran
var test_sum := 0.0 #Total of all 10 tests for this benchmark

var measuring := false #Should delta be measuring frames right now?

var frame_counter := 0 #How many frames have passed?
var warmup_frames := 100 #Number of frames to wait until script should measure
var measure_frames := 150 #Number of frames we will measure the time of

var time_accum_sec := 0.0 #Total time accumulated in seconds?

#===============================================================================
# Entering function - Default node benchmark takes too long for more than 10_000
# nodes. Calls each step in the benchmark and returns the avg process time.
func node_benchmark(npc_count: int) -> float:
	if npc_count > 10_000:
		print("Default-Node(", npc_count, " NPCs): N/A")
		return -1
	
	reset_vars()
	spawn_npcs(npc_count)
	var msec_avg : float = await measure_benchmark(npc_count)
	cleanup_npcs(npc_count)
	
	return msec_avg

#===============================================================================
# Initiates measuring in _process() and waits until all 10 test are done. It 
# then takes the avg of the 10 tests and returns the avg to the main benchmark
# script.
func measure_benchmark(npc_count: int) -> float:
	printraw("Default-Node(", npc_count, " NPCs): ")
	
	measuring = true
	
	while measuring:
		await get_tree().process_frame
	
	var avg = (test_sum / test_counter)
	print("%.2f" % avg, " ms")
	return avg

#===============================================================================
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Records the frame time and increments the frame counter. Once 
# "measuring frames" are reached, the avg time is taken and the test counter
# is incremented. Once 10 tests are completed, stops measuring frame times.
func _process(delta: float) -> void:
	if not measuring:
		return
	
	if test_counter >= 10:
		measuring = false
		return
		
	if frame_counter >= warmup_frames:
		time_accum_sec += Performance.get_monitor(Performance.TIME_PROCESS)
	
	frame_counter += 1
	
	if frame_counter >= warmup_frames + measure_frames:
		test_sum += (time_accum_sec / measure_frames) * 1000.0
		test_counter += 1
		frame_counter = warmup_frames - 1
		time_accum_sec = 0.0
		printraw(".")

#===============================================================================
# Resets all variables between tests so proper times are recorded.
func reset_vars():
	measuring = false
	test_counter = 0
	test_sum = 0.0
	frame_counter = 0
	time_accum_sec = 0.0

#===============================================================================
# Iterate for range(npc_count) to spawn npc nodes. Instantiates node, adds it 
# to the npcs array, then adds it to the scene tree
func spawn_npcs(npc_count: int):
	for i in range(npc_count):
			var npc = npc_scene.instantiate()
			npcs.append(npc)
			add_child(npc)

#===============================================================================
#Destroy all instantiated NPCs and clear npc array to prepare for next test
func cleanup_npcs(npc_count: int):
	for i in range(npc_count):
		npcs[i].queue_free()
	npcs.clear()
	await get_tree().process_frame
