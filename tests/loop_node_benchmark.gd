extends Node

@export var npc_scene : PackedScene #NPC node scene reference

var npcs := [] #Array of instantiated NPC nodes

var test_counter := 0 #Counter for no of tests ran
var test_sum := 0.0 #Total of all 10 tests for this benchmark

var time_accum_sec := 0.0 #Total time accumulated in seconds?
var start_time: float
var end_time: float

var frame_counter := 0 #How many frames have passed?
var warmup_frames := 100 #Number of frames to wait until script should measure
var measure_frames := 150 #Number of frames we will measure the time of

var copy_delta := 16.6 #Fake frame time (ms)

#===============================================================================

func node_benchmark(npc_count: int) -> float:
	if npc_count > 100_000:
		print(npc_count, ": N/A")
		return -1
	
	reset_vars()
	spawn_npcs(npc_count)
	var msec_avg : float = measure_benchmark(npc_count)
	cleanup_npcs(npc_count)
	
	return msec_avg

#===============================================================================
# Returns the avg frame time in ms after running 10 tests of 150 frames
func measure_benchmark(npc_count: int) -> float:
	printraw("Loop-Node(", npc_count, " NPCs): ")
	
	while test_counter < 10:
		frames()
	
	var avg = (test_sum / test_counter)
	print("%.2f" % avg, " ms")
	return avg

#===============================================================================

func frames():
	if frame_counter >= warmup_frames:
		start_time = Time.get_ticks_usec()
		for npc in npcs:
			npc.position = npc.velocity * copy_delta
		end_time = Time.get_ticks_usec()
		var frame_ms = (end_time - start_time) / 1000.0
		time_accum_sec += frame_ms
	
	frame_counter += 1
	
	if frame_counter >= warmup_frames + measure_frames:
		test_sum += time_accum_sec / measure_frames
		test_counter += 1
		frame_counter = warmup_frames - 1
		time_accum_sec = 0.0
		printraw(".")

#===============================================================================

func reset_vars():
	test_counter = 0
	test_sum = 0.0
	frame_counter = 0
	time_accum_sec = 0.0

#===============================================================================

func spawn_npcs(npc_count: int):
	for i in npc_count:
			var npc = npc_scene.instantiate()
			npc.set_process(false)
			npcs.append(npc)
			add_child(npc)
 
#===============================================================================
#Destroy all instantiated NPCs and clear npc array to prepare for next test
func cleanup_npcs(npc_count: int):
	for i in npc_count:
		npcs[i].queue_free()
	npcs.clear()
	await get_tree().process_frame
