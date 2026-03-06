extends Node

var pos : PackedVector3Array
var vel : PackedVector3Array
var thread_count := 6 #Matching threads to physical cores
var threads := []
var chunk_size
var start_idx
var end_idx

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
	
	reset_vars()
	initialize_npc_arrays(npc_count)
	var msec_avg : float = measure_benchmark(npc_count)
	cleanup_npc_arrays()
	
	return msec_avg

#===============================================================================
func measure_benchmark(npc_count: int) -> float:
	printraw("SoA SIMD Threads: ", thread_count, " (", npc_count, " NPCs): ")
	
	chunk_size = npc_count / thread_count
	for i in range(thread_count):
		var thread = Thread.new()
		threads.append(thread)
	
	while test_counter < 10:
		frames(npc_count)
	
	var avg = (test_sum / test_counter)
	print("%.2f" % avg, " ms")
	return avg

#===============================================================================
func frames(npc_count: int):
	threads.clear()
	start_time = Time.get_ticks_usec()
	for t in range(thread_count):
		var thread = Thread.new()
		threads.append(thread)
		var start_idx = t * chunk_size
		var end_idx = min(start_idx + chunk_size, npc_count)
		thread.start(_update_chunk.bind(start_idx, end_idx, copy_delta))
	for thread in threads:
		thread.wait_to_finish()
	end_time = Time.get_ticks_usec()
	var frame_ms = (end_time - start_time) / 1000.0
	time_accum_sec += frame_ms
	
	frame_counter += 1
	
	if frame_counter >= measure_frames:
		test_sum += time_accum_sec / measure_frames
		test_counter += 1
		frame_counter = 0
		time_accum_sec = 0.0
		printraw(".")

#===============================================================================
func _update_chunk(start_idx, end_idx, delta):
	var d = delta
	for i in range(start_idx, end_idx):
		pos[i] += vel[i] * d

#===============================================================================
func reset_vars():
	test_counter = 0
	test_sum = 0.0
	frame_counter = 0
	time_accum_sec = 0.0

#===============================================================================
func initialize_npc_arrays(npc_count: int):
	pos.resize(npc_count)
	vel.resize(npc_count)
	
	for i in range(npc_count):
		pos[i] = Vector3(0.0, 0.0, 0.0)
		vel[i] = Vector3(randf(), 0.0, randf())

#===============================================================================
func cleanup_npc_arrays():
	pos.clear()
	pos.clear()
	
	await get_tree().process_frame
